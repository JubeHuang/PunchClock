//
//  TimeRecord.swift
//  PunchClock
//
//  Created by Jube on 2023/7/11.
//
import FirebaseFirestoreSwift
import FirebaseFirestore

struct TimeRecord: Codable, Identifiable {
    
    @DocumentID var id: String?
    var inTime: Date?
    var outTime: Date?
    var documentID: String?
    
    var punchIn: Timestamp? {
        guard let inTime = inTime else { return nil }
        return Timestamp(date: inTime)
    }
    var punchOut: Timestamp? {
        guard let outTime = outTime else { return nil }
        return Timestamp(date: outTime)
    }
    
    var data: [String: Any] {
        var data: [String: Any] = [:]
        
        if let punchIn {
            data["punchIn"] = punchIn
        }
        if let punchOut {
            data["punchOut"] = punchOut
        }
        return data
    }
}

extension TimeRecord {
    
    // save in and out
    init(in: Date? = nil, out: Date? = nil) {
        self.inTime = `in`
        self.outTime = out
    }
    
    // read
    init(in: Date? = nil, out: Date? = nil, id: String) {
        self.inTime = `in`
        self.outTime = out
        self.documentID = id
    }
    
    var inTimeString: String {
        self.inTime?.toString(dateFormat: .hourMinute) ?? "尚未打卡"
    }
    
    var outTimeString: String {
        self.outTime?.toString(dateFormat: .hourMinute) ?? "尚未打卡"
    }
}
