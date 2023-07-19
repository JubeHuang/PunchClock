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
    
//    func createSingleTimeData(month: String, time: Date, isPunchIn: Bool) {
//        guard let path = getPath(month: month) else { return }
//        
//        var record: TimeRecord = TimeRecord()
//        
//        if isPunchIn {
//            record = TimeRecord(in: time)
//        } else {
//            record = TimeRecord(out: time)
//        }
//        
//        db.collection(path).addDocument(data: record.data) { [weak self] error in
//            guard let self else { return }
//            self.errorLog(error,
//                          errorTitle: "Adding Data Error",
//                          successTitle: "Data Added")
//        }
//    }
    
    func deleteData(month: String, at index: Int, in: Date?, out: Date?) {
        getDocumentID(month: month, at: index) { [weak self] path, documentID in
            guard let self else { return }
            
            self.db.collection(path).document(documentID).delete()
        }
    }
    
    func updateData(month: String, index: Int, in: Date?, out: Date?) {
        let record = TimeRecord(in: `in`, out: out)
        
        getDocumentID(month: month, at: index) { [weak self] path, documentID in
            guard let self else { return }
            
            self.db.collection(path)
                .document(documentID)
                .updateData(record.data) { error in
                    self.errorLog(error,
                                  errorTitle: "Update Time Error",
                                  successTitle: "Time Updated",
                                  successMsg: "in: \(record.inTime?.toString() ?? "No Update"), out: \(record.outTime?.toString() ?? "No Update")")
                }
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
