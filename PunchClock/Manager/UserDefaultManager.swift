//
//  UserDefaultManager.swift
//  PunchClock
//
//  Created by Jube on 2023/8/9.
//

import Foundation

class UserDefaultManager {
    
    private static let punchInKey = UserDefaultKey.punchInDate.rawValue
    private static let punchOutKey = UserDefaultKey.punchOutDate.rawValue
    private static let workingHoursKey = UserDefaultKey.workingHours.rawValue
    
    static func getPunchInTime() -> Date? {
        UserDefaults.standard.object(forKey: punchInKey) as? Date
    }
    
    static func getPunchOutTime() -> Date? {
        UserDefaults.standard.object(forKey: punchOutKey) as? Date
    }
    
    static func savePunchInTime(_ date: Date) {
        UserDefaults.standard.setValue(date, forKey: punchInKey)
        print(date, "saved")
        
        let workingHours = getWorkingHours()
        if workingHours > 0 {
            let hour = Int(workingHours)
            let min = Int(workingHours * 10) % 10
            if let punchOutTime = Calendar.current.date(bySettingHour: hour, minute: min, second: 0, of: date) {
                savePunchOutTime(punchOutTime)
            }
        }
    }
    
    static func savePunchOutTime(_ date: Date) {
        UserDefaults.standard.setValue(date, forKey: punchOutKey)
    }
    
    static func removePunchInTime() {
        UserDefaults.standard.removeObject(forKey: punchInKey)
    }
    
    static func getWorkingHours() -> Double {
        UserDefaults.standard.double(forKey: workingHoursKey)
    }
    
    static func saveWorkingHours(_ hours:  Double) {
        UserDefaults.standard.set(hours, forKey: workingHoursKey)
    }
}

enum UserDefaultKey: String {
    
    case punchInDate
    case punchOutDate
    case workingHours
}
