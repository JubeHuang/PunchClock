//
//  PunchClockViewModel.swift
//  PunchClock
//
//  Created by Jube on 2023/7/13.
//

import Foundation
import Combine
import UIKit

class PunchClockViewModel {
    
    private let storeManager = FirestoreManager()
    
    var timerSubscriber: AnyCancellable?
    
    var isCheckIn: Bool = false
    var isCheckOut: Bool = false
    
    var punchInTimeStr: String?
    var punchOutTimeStr: String?
    
    @Published var workingHour: Double = 9
    @Published var workingHourStr: String?
    
    @Published var dateStr: String = { Date().toString(dateFormat: .yearMonthDate) }()
    @Published var weekDayStr: String = { Date().toString(dateFormat: .weekday) }()
    @Published var currentTimeStr: String = { Date().toString(dateFormat: .hourMinute) }()
    
    @Published var quoteSubject: String = "今天的語錄尚未抵達，不要著急，因為明天可能也到不了。"
    
    var weatherIcon: UIImage = {
        
       return UIImage(named: "04")!
    }()
    
    init() {
        $workingHour
            .map { hours in
                let roundedHours = Int(hours * 10) % 10 == 0 ? hours.rounded() : hours
                return "努力工作 \(roundedHours) 小時"
            }
            .assign(to: &$workingHourStr)
        
        getTime()
        loadQuote()
    }
}

extension PunchClockViewModel {
    
    func getTime() {
        timerSubscriber = Timer.publish(every: 1, on: .main, in: .default).autoconnect()
            .sink(receiveValue: { [weak self] currentTime in
                self?.currentTimeStr = currentTime.toString(dateFormat: .hourMinute)
        })
    }
    
    func cancelTimer() {
        self.timerSubscriber?.cancel()
    }
    
    func loadQuote() {
        storeManager.getQuote { [weak self] quote in
            self?.quoteSubject = quote
        }
    }
}
