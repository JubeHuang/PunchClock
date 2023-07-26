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
    
    func fetchData(month: String, completeHandler: @escaping([TimeRecord]) -> Void) {
        guard let path = getPath(month: month) else { return }
        
        db.collection(path)
            .order(by: "punchIn", descending: false)
            .getDocuments { [weak self] snapshots, error in
                
                guard let snapshots else {
                    self?.errorLog(error, errorTitle: "Read Data Error", successTitle: "Data Read")
                    return
                }
                
                let timeRecords: [TimeRecord] = snapshots.documents.compactMap { document in
                    let dic = document.data()
                    guard let inTimestamp = dic["punchIn"] as? Timestamp,
                          let outTimestamp = dic["punchOut"] as? Timestamp else {
                        return nil
                    }
                    
                    return TimeRecord(in: inTimestamp.dateValue(), out: outTimestamp.dateValue())
                }
                completeHandler(timeRecords)
            }
    }
    
    func createData(month: String, in: Date? = nil, out: Date? = nil) {
        guard let path = getPath(month: month) else { return }
        
        let record = TimeRecord(in: `in`, out: out)
        
        db.collection(path).addDocument(data: record.data) { [weak self] error in
            guard let self else { return }
            self.errorLog(error,
                          errorTitle: "Adding Data Error",
                          successTitle: "Data Added")
        }
    }
    
    func deleteData(month: String, at index: Int) {
        getDocumentID(month: month, at: index) { [weak self] path, documentID in
            guard let self else { return }
            
            self.db.collection(path).document(documentID).delete()
        }
    }
    
    func updateData(month: String, index: Int, in: Date? = nil, out: Date? = nil) {
        let record = TimeRecord(in: `in`, out: out)
        
        getDocumentID(month: month, at: index) { [weak self] path, documentID in
            guard let self else { return }
            
            self.db.collection(path)
                .document(documentID)
                .updateData(record.data) { error in
                    self.errorLog(error,
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
                      let quote = try? snapshots.data(as: Quote.self).quote else {
                    self?.errorLog(error, errorTitle: "Read Quote Error", successTitle: "Quote Read")
                    
                    completion("今天的語錄尚未抵達，不要著急，因為明天可能也到不了。")
                    return
                }
                
                completion(quote)
            }
    }
    
    private func getPath(month: String) -> String? {
        guard let accountMd5 else {
            print("====== Unauthorized ======\n Cannot Upload Data.")
            return nil
        }
        
        let path = "\(accountMd5)/\(month)/TimeRecords"
        return path
    }
    
    private func getDocumentID(month: String, at index: Int, completeHandler: @escaping(String, String) -> Void) {
        guard let path = getPath(month: month) else { return }
        
        db.collection(path)
            .order(by: "punchIn", descending: false)
            .getDocuments { [weak self] snapshots, error in
                
                guard let self, let snapshots else { return }
                
                completeHandler(path, snapshots.documents[index].documentID)
                
                self.errorLog(error,
                              errorTitle: "Read Data Error",
                              successTitle: "Data Read")
            }
    }
    
    private func errorLog(_ error: Error?, errorTitle: String, successTitle: String, successMsg: String? = nil) {
        if let error {
            print("====== \(errorTitle) ======\nError: \(error.localizedDescription)")
            return
        }
        print("====== \(successTitle) ======\n\(successMsg ?? "")")
    }
    
}
