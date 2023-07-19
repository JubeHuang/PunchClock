//
//  PunchClockViewModel.swift
//  PunchClock
//
//  Created by Jube on 2023/7/13.
//

import Foundation
import Combine

struct PunchClockViewModel {
    
    var cancellable: AnyCancellable?
    
    var punchInTimeStr: String?
    var punchOutTimeStr: String?
    
    var workingHour: Double = 9
    var workingHourStr: String { "努力工作 \(workingHour) 小時" }
    
    var todayStr: String { Date().toDateString() }
}

extension PunchClockViewModel {
    
    mutating func getTime(completeHandler: @escaping (Publishers.Autoconnect<Timer.TimerPublisher>.Output) -> Void) {
        self.cancellable = Timer.publish(every: 1, on: .main, in: .common).autoconnect().sink(receiveValue: { value in
            completeHandler(value)
        })
    }
    
    mutating func cancelTimer() {
        self.cancellable?.cancel()
    }
}
