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
    
    var cancellable: AnyCancellable?
    
    var isCheckIn: Bool = false
    var isCheckOut: Bool = false
    
    var punchInTimeStr: String?
    var punchOutTimeStr: String?
    
    @Published var workingHour: Double = 9
    @Published var workingHourStr: String?
    
    @Published var dateStr: String = { Date().toString(dateFormat: DateFormat.yearMonthDate.rawValue) }()
    @Published var weekDayStr: String = { Date().toString(dateFormat: DateFormat.weekday.rawValue) }()
    @Published var nowStr: String = { Date().toString(dateFormat: DateFormat.hourMinute.rawValue) }()
    
    @Published var quoteSubject: String = "今天的語錄尚未抵達，不要著急，因為明天可能也到不了。"
    
    var weatherIcon: UIImage = {
        
       return UIImage(named: "noData")!
    }()
    
    init() {
        $workingHour
            .map { "努力工作 \($0) 小時" }
            .assign(to: &$workingHourStr)
    }
}

extension PunchClockViewModel {
    
    func getTime(completeHandler: @escaping (Publishers.Autoconnect<Timer.TimerPublisher>.Output) -> Void) {
        self.cancellable = Timer.publish(every: 1, on: .main, in: .common).autoconnect().sink(receiveValue: { value in
            completeHandler(value)
        })
    }
    
    func cancelTimer() {
        self.cancellable?.cancel()
    }
    
    func loadQuote() {
        storeManager.getQuote { [weak self] quote in
            self?.quoteSubject = quote
        }
    }
}
