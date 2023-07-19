//
//  RecordListViewModel.swift
//  PunchClock
//
//  Created by Jube on 2023/7/13.
//

import Foundation

class RecordListViewModel {
    
//    var recordsViewModel: [TimeRecord]
    
    var records: [TimeRecord]
    
    var monthString = Date().toMonthString()
    
    init() {
//        self.recordsViewModel = [TimeRecord]()
        self.records = [TimeRecord()]
        
        fetchData()
    }
}

extension RecordListViewModel {
    
    func recordsViewModel(at index: Int) -> TimeRecord {
        return self.records[index]
    }
    
    func fetchData() {
        FirestoreManager().fetchData(month: monthString) { self.records = $0 }
    }
}
