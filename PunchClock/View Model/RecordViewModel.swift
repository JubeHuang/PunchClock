//
//  Punch View Model.swift
//  PunchClock
//
//  Created by Jube on 2023/7/13.
//

struct RecordViewModel {
    
    var record: TimeRecord
}

extension RecordViewModel {
    
    var inTime: String? {
        self.record.inTime?.toString()
    }
    
    var outTime: String? {
        self.record.outTime?.toString()
    }
}
