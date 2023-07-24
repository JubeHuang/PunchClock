//
//  RecordListViewModel.swift
//  PunchClock
//
//  Created by Jube on 2023/7/13.
//

import Foundation
import Combine

class RecordListViewModel: RecordsType {
    
    func searchRecords(in month: String) -> AnyPublisher<[TimeRecord], Never> {
    }
    
    func recordDetail(with id: String, in month: String) -> AnyPublisher<TimeRecord, Never> {
        <#code#>
    }
    
    
//    var recordsViewModel: [TimeRecord]
    
    var records: [TimeRecord]
    
    var monthString = Date().toString(dateFormat: DateFormat.month.rawValue)
    
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
