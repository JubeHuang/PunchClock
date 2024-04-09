//
//  EditTimeViewModel.swift
//  PunchClock
//
//  Created by Jube on 2023/9/13.
//

import Foundation

typealias DataInfo = (month: String, year: String, inTime: String, outTime: String?, index: Int, id: String)

class EditTimeViewModel {
    
    var dataInfo: DataInfo
    
    let firestoreManager = FirestoreManager()
    
    
    
    init(dataInfo: DataInfo) {
        self.dataInfo = dataInfo
    }
    
    func delete() {
        firestoreManager.deleteData(in: (dataInfo.month, dataInfo.year), at: dataInfo.index, with: dataInfo.id)
    }
}
