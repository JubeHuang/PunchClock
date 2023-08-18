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
    
    private weak var pushManager = PushManager.shared
    
    @Published var workingHours: Double
    
    @Published var isOffWorkPushOn: Bool = false
    @Published var isAutoPunchOutOn: Bool = false
    
    lazy var isAddBtnEnabled: Bool = true
    lazy var isMinusBtnEnabled: Bool = true
    
    let maxHours = 24.0
    let minHours = 0.0
    let gap = 0.5
    
    init(workingHours: Double) {
        self.workingHours = UserDefaultManager.getWorkingHours() > minHours ? UserDefaultManager.getWorkingHours() : workingHours
        
        pushManager?.delegate = self
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

            pushManager?.createPunchOutPushNotification(on: suggestTime)
        }
    }
    
    func checkPushState() {
        pushManager?.checkStatus(on: Date())
    }
    
    func syncPushStatus() {
        pushManager?.syncStatus()
    }
}

extension SettingViewModel: PushManagerDelegate {
    
    func pushManagerDelegate(_ controller: PushManager, isOffWorkPushOn: Bool) {
        self.isOffWorkPushOn = isOffWorkPushOn
    }
}
