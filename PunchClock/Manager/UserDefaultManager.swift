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
    private static let autoPunchOutKey = UserDefaultKey.autoPunchOutState.rawValue
    
    static func getPunchInTime() -> Date? {
        UserDefaults.standard.object(forKey: punchInKey) as? Date
    }
    
    static func getPunchOutTime() -> Date? {
        UserDefaults.standard.object(forKey: punchOutKey) as? Date
    }
    
    static func savePunchInTime(_ date: Date) {
        UserDefaults.standard.setValue(date, forKey: punchInKey)
        print(date, "saved PubchIn")
        
        let workingHours = getWorkingHours()
        let seconds = workingHours * 3600
        savePunchOutTime(date.addingTimeInterval(seconds))
    }
    
    static func getAutoPunchOutState() -> Bool {
        UserDefaults.standard.bool(forKey: autoPunchOutKey)
    }
    
    static func savePunchOutTime(_ date: Date) {
        UserDefaults.standard.setValue(date, forKey: punchOutKey)
        print(date, "saved PunchOut")
    }
    
    static func removeAllPunchTime() {
        UserDefaults.standard.removeObject(forKey: punchInKey)
        UserDefaults.standard.removeObject(forKey: punchOutKey)
    }
    
    static func getWorkingHours() -> Double {
        UserDefaults.standard.double(forKey: workingHoursKey)
    }
    
    static func saveWorkingHours(_ hours:  Double) {
        UserDefaults.standard.set(hours, forKey: workingHoursKey)
    }
    
    static func saveAutoPunchOutState(isOn: Bool) {
        UserDefaults.standard.set(isOn, forKey: autoPunchOutKey)
    }
}

enum UserDefaultKey: String {
    
    case punchInDate
    case punchOutDate
    case workingHours
    case autoPunchOutState
}
