//
//  PunchClockViewModel.swift
//  PunchClock
//
//  Created by Jube on 2023/7/13.
//

import Foundation
import Combine
import UIKit

struct PunchClockViewModel {
    
    var cancellable: AnyCancellable?
    
    var isCheckIn: Bool = false
    var isCheckOut: Bool = false
    
    var punchInTimeStr: String?
    var punchOutTimeStr: String?
    
    var workingHour: Double = 9
    var workingHourStr: String { "努力工作 \(workingHour) 小時" }
    
    var dateStr: String { Date().toString(dateFormat: DateFormat.yearMonthDate.rawValue) }
    var weekDayStr: String { Date().toString(dateFormat: DateFormat.weekday.rawValue) }
    var nowStr: String { Date().toString(dateFormat: DateFormat.hourMinute.rawValue) }
    
    var weatherIcon: UIImage = {
        
       return UIImage(named: "noData")!
    }()
    
    init() {
        
    }
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
