//
//  UserDefaultManager.swift
//  PunchClock
//
//  Created by Jube on 2023/8/9.
//

import Foundation

class UserDefaultManager {
    
    private static let punchInKey = UserDefaultKey.punchInDate.rawValue
    
    static func getPunchInTime() -> Date? {
        let punchInTime = UserDefaults.standard.object(forKey: punchInKey) as? Date
        return punchInTime
    }
    
    static func savePunchInTime(_ date: Date) {
        UserDefaults.standard.setValue(date, forKey: punchInKey)
        print(date, "saved")
    }
    
    static func removePunchInTime() {
        UserDefaults.standard.removeObject(forKey: punchInKey)
    }
}

enum UserDefaultKey: String {
    
    case punchInDate
}
