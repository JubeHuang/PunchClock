//
//  EditTimeViewModel.swift
//  PunchClock
//
//  Created by Jube on 2023/9/13.
//

import Foundation

typealias DataInfo = (month: String, inTime: String, outTime: String?, index: Int, id: String)

class EditTimeViewModel {
    
    var dataInfo: DataInfo
    
    let firestore = FirestoreManager()
    
    init(dataInfo: DataInfo) {
        self.dataInfo = dataInfo
    }
    
    func delete() {
        firestore.deleteData(in: dataInfo.month, at: dataInfo.index, with: dataInfo.id)
    }
}
