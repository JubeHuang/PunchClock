//
//  FirestoreManager.swift
//  PunchClock
//
//  Created by Jube on 2023/7/11.
//

import FirebaseCore
import FirebaseFirestore

class FirestoreManager {
    
    private let db = Firestore.firestore()
    
    private var accountMd5: String? { LogInManager().account?.md5 }
    
    private let testMode = "jubeTest"
    
    func fetchData(in month: String, completeHandler: @escaping([TimeRecord]) -> Void) {
        guard let path = getPath(month: month) else { return }
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
                print(timeRecords.count, "fetch from firestore")
                completeHandler(timeRecords)
                
                self?.log(successTitle: "Data Fetched Success")
            }
    }
    
    func createData(in month: String, in: Date? = nil, out: Date? = nil) {
        guard let path = getPath(month: month) else { return }
        
        let record = TimeRecord(in: `in`, out: out)
        
        db.collection(path).addDocument(data: record.data) { [weak self] error in
            self?.log(error,
                          errorTitle: "Adding Data Error",
                          successTitle: "Data Added Success")
        }
    }
    
    func deleteData(in month: String, at index: Int, with id: String) {
        getDocumentID(month: month, at: index) { [weak self] path, documentID in
            if id == documentID {
                self?.db.collection(path).document(documentID).delete()
                
                self?.log(successTitle: "Data Deleted Success")
            } else {
                self?.log(errorTitle: "Data Delete Error DoumentID Not Match")
            }
        }
    }
    
    func updateData(month: String, index: Int, in: Date? = nil, out: Date? = nil) {
        let record = TimeRecord(in: `in`, out: out)
        
        getDocumentID(month: month, at: index) { [weak self] path, documentID in
            guard let self else { return }
            
            self.db.collection(path)
                .document(documentID)
                .updateData(record.data) { error in
                    self.log(error,
                             errorTitle: "Update Time Error",
                             successTitle: "Time Updated",
                             successMsg: "in: \(record.inTimeString), out: \(record.outTimeString)")
                }
        }
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
    
    private func getPath(month: String) -> String? {
//        guard let accountMd5 else {
//            print("====== Unauthorized ======\nCannot Upload Data.")
//            return nil
//        }
        
//        let path = "\(accountMd5)/\(month)/TimeRecords"
        let path = "\(testMode)/\(month)/TimeRecords"
        return path
    }
    
    private func getDocumentID(month: String, at index: Int, completeHandler: @escaping(String, String) -> Void) {
        guard let path = getPath(month: month) else { return }
        
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
