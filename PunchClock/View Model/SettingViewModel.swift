//
//  SettingViewModel.swift
//  PunchClock
//
//  Created by Jube on 2023/7/13.
//

import Foundation
import Combine

class SettingViewModel {
    
    var workingHours: Double = 9
    
    @Published var isOffWorkPushOn: Bool = false
    @Published var isAutoPunchOutOn: Bool = false
    
    init() {
        
    }
}

extension SettingViewModel {
    
    func addHours() {
        
    }
}
