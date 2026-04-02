//
//  SettingViewModel.swift
//  PunchClock
//
//  Created by Jube on 2023/7/13.
//

import Foundation
import Combine
import UIKit.UIViewController

class SettingViewModel {
    
    private let pushManager = PushManager.shared
    private var shouldPersistPushState = true
    
    @Published var workingHours: Double = 9.0
    @Published var isOffWorkPushOn: Bool = false {
        didSet {
            guard shouldPersistPushState else { return }
            UserDefaultManager.saveOffWorkPushState(isOn: isOffWorkPushOn)
        }
    }
    @Published var isAutoPunchOutOn: Bool = false {
        didSet {
            UserDefaultManager.saveAutoPunchOutState(isOn: isAutoPunchOutOn)
        }
    }
    
    lazy var isAddBtnEnabled: Bool = true
    lazy var isMinusBtnEnabled: Bool = true
    
    let maxHours = 24.0
    let minHours = 0.5
    let gap = 0.5
    
    init() {
        self.workingHours = UserDefaultManager.getWorkingHours() >= minHours ? UserDefaultManager.getWorkingHours() : workingHours
        self.isOffWorkPushOn = UserDefaultManager.getOffWorkPushState()
        self.isAutoPunchOutOn = UserDefaultManager.getAutoPunchOutState()
    }
}

extension SettingViewModel {
    
    func addHours() {
        if workingHours < maxHours {
            workingHours += gap
        }
        
        isAddBtnEnabled = workingHours != maxHours
        isMinusBtnEnabled = workingHours != minHours
    }
    
    func minusHours() {
        if workingHours > minHours {
            workingHours -= gap
        }
        
        isAddBtnEnabled = workingHours != maxHours
        isMinusBtnEnabled = workingHours != minHours
    }
    
    func saveDataToUserDefault() {
        UserDefaultManager.saveWorkingHours(workingHours)
        
        if isOffWorkPushOn,
           let punchInTime = UserDefaultManager.getPunchInTime() {
            let timeInterval = workingHours * 60 * 60
            let suggestTime = punchInTime.addingTimeInterval(timeInterval)

            pushManager.removePunchOutPushNotification()
            pushManager.createPunchOutPushNotification(on: suggestTime)
            
            if isAutoPunchOutOn {
                UserDefaultManager.savePunchInTime(punchInTime)
            }
        }
    }
    
    func updatePushState(isOn: Bool) {
        if isOn {
            pushManager.enablePunchOutPush(on: currentSuggestTime) { [weak self] isAuthorized in
                self?.setPushState(UserDefaultManager.getOffWorkPushState() && isAuthorized, persist: false)
                if isAuthorized {
                    self?.setPushState(true)
                }
            }
        } else {
            pushManager.removePunchOutPushNotification()
            setPushState(false)
        }
    }
    
    func syncPushStatus() {
        let savedState = UserDefaultManager.getOffWorkPushState()
        pushManager.syncStatus { [weak self] isAuthorized in
            self?.setPushState(savedState && isAuthorized, persist: false)
        }
    }
    
    private var currentSuggestTime: Date? {
        guard let punchInTime = UserDefaultManager.getPunchInTime() else { return nil }
        let timeInterval = workingHours * 60 * 60
        return punchInTime.addingTimeInterval(timeInterval)
    }
    
    private func setPushState(_ isOn: Bool, persist: Bool = true) {
        shouldPersistPushState = persist
        isOffWorkPushOn = isOn
        shouldPersistPushState = true
    }
}
