//
//  FirestoreManager.swift
//  PunchClock
//
//  Created by Jube on 2023/7/11.
//

import FirebaseCore
import FirebaseFirestore

class FirestoreManager {
    
    typealias MonthYear = (month: String, year: String)
    
    private static var recordsCache = [String: [TimeRecord]]()
    
    private let db = Firestore.firestore()
    
    private var accountMd5: String? { LogInManager().account?.md5 }
    
    private let testMode = "jubeTest"
    
    func fetchData(in time: MonthYear, completeHandler: @escaping([TimeRecord]) -> Void) {
        let cacheKey = cacheKey(for: time)
        if let cachedRecords = Self.recordsCache[cacheKey] {
            completeHandler(cachedRecords)
            return
        }
        
        guard let path = getPath(time: time) else { return }
        print(path)
        db.collection(path)
            .order(by: "punchIn", descending: false)
            .getDocuments { [weak self] snapshots, error in
                
                guard let snapshots else {
                    self?.log(error, errorTitle: "Read Data Error")
                    return
                }
                
                let timeRecords: [TimeRecord] = snapshots.documents.compactMap { document in
                    let dic = document.data()
                    guard let inTimestamp = dic["punchIn"] as? Timestamp,
                          let outTimestamp = dic["punchOut"] as? Timestamp else {
                        return nil
                    }
                    
                    return TimeRecord(in: inTimestamp.dateValue(), out: outTimestamp.dateValue(), id: document.documentID)
                }
                Self.recordsCache[cacheKey] = timeRecords
                print(timeRecords.count, "fetch from firestore")
                completeHandler(timeRecords)
                
                self?.log(successTitle: "Data Fetched Success")
            }
    }
    
    func createData(in time: MonthYear, in: Date? = nil, out: Date? = nil) {
        guard let path = getPath(time: time) else { return }
        
        let document = db.collection(path).document()
        let record = TimeRecord(in: `in`, out: out, id: document.documentID)
        
        upsertCachedRecord(record, in: time)
        
        document.setData(record.data) { [weak self] error in
            self?.log(error,
                          errorTitle: "Adding Data Error",
                          successTitle: "Data Added Success")
        }
    }
    
    func deleteData(in time: MonthYear, at index: Int, with id: String) {
        removeCachedRecord(in: time, with: id)
        
        getDocumentID(time: time, at: index) { [weak self] path, documentID in
            if id == documentID {
                self?.db.collection(path).document(documentID).delete()
                
                self?.log(successTitle: "Data Deleted Success")
            } else {
                self?.log(errorTitle: "Data Delete Error DoumentID Not Match")
            }
        }
    }
    
    func updateData(in time: MonthYear, index: Int, in: Date? = nil, out: Date? = nil) {
        guard let cachedRecord = cachedRecords(in: time).safeElement(at: index),
              let documentID = cachedRecord.documentID else {
            return
        }
        
        let record = TimeRecord(in: `in`, out: out, id: documentID)
        upsertCachedRecord(record, in: time)
        
        getDocumentID(time: time, at: index) { [weak self] path, fetchedDocumentID in
            guard let self else { return }
            guard documentID == fetchedDocumentID else {
                self.log(errorTitle: "Update Time Error DocumentID Not Match")
                return
            }
            
            self.db.collection(path)
                .document(fetchedDocumentID)
                .updateData(record.data) { error in
                    self.log(error,
                             errorTitle: "Update Time Error",
                             successTitle: "Time Updated",
                             successMsg: "in: \(record.inTimeString), out: \(record.outTimeString)")
                }
        }
    }
    
    func cachedRecords(in time: MonthYear) -> [TimeRecord] {
        Self.recordsCache[cacheKey(for: time)] ?? []
    }
    
    func getQuote(completion: @escaping (String) -> Void) {
        let randomInt = Int.random(in: 0...11)
        
        db.collection("quote")
            .document("\(randomInt)")
            .getDocument { [weak self] snapshots, error in
                
                guard let snapshots,
                      snapshots.exists,
                      let quote = try? snapshots.data(as: QuoteResponse.self).quote else {
                    self?.log(error,
                              errorTitle: "Read Quote Error",
                              successTitle: "Quote Read Success")
                    
                    completion(Wording.defaultQuote.text)
                    return
                }
                
                completion(quote)
            }
    }
    
    private func getPath(time: MonthYear) -> String? {
//        guard let accountMd5 else {
//            print("====== Unauthorized ======\nCannot Upload Data.")
//            return nil
//        }
        
//        let path = "\(accountMd5)/\(month)/TimeRecords"
        let path = "\(testMode)/\(time.month)\(time.year)/TimeRecords"
        return path
    }
    
    private func cacheKey(for time: MonthYear) -> String {
        "\(time.month)-\(time.year)"
    }
    
    private func upsertCachedRecord(_ record: TimeRecord, in time: MonthYear) {
        let key = cacheKey(for: time)
        var records = Self.recordsCache[key] ?? []
        
        if let recordID = record.documentID,
           let index = records.firstIndex(where: { $0.documentID == recordID }) {
            records[index] = record
        } else {
            records.append(record)
        }
        
        Self.recordsCache[key] = records.sorted {
            ($0.inTime ?? .distantPast) < ($1.inTime ?? .distantPast)
        }
    }
    
    private func removeCachedRecord(in time: MonthYear, with documentID: String) {
        let key = cacheKey(for: time)
        guard var records = Self.recordsCache[key] else { return }
        
        records.removeAll { $0.documentID == documentID }
        Self.recordsCache[key] = records
    }
    
    private func getDocumentID(time: MonthYear, at index: Int, completeHandler: @escaping(String, String) -> Void) {
        guard let path = getPath(time: time) else { return }
        
        db.collection(path)
            .order(by: "punchIn", descending: false)
            .getDocuments { [weak self] snapshots, error in
                
                guard let self, let snapshots else { return }
                
                completeHandler(path, snapshots.documents[index].documentID)
                
                self.log(error,
                         errorTitle: "Read Data Error",
                         successTitle: "Data Read")
            }
    }
    
    private func log(_ error: Error? = nil, errorTitle: String? = nil, successTitle: String? = nil, successMsg: String? = nil) {
        if let error, let errorTitle {
            print("====== \(errorTitle) ======\nError: \(error.localizedDescription)")
            return
        }
        
        if let successTitle {
            print("====== \(successTitle) ======\n\(successMsg ?? "")")
            return
        }
        
        if let errorTitle {
            print("====== \(errorTitle) ======")
            return
        }
    }
    
}

private extension Array {
    func safeElement(at index: Int) -> Element? {
        indices.contains(index) ? self[index] : nil
    }
}
