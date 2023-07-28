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
    var cancellable = Set<AnyCancellable>()
    
    @Published var isCheckIn: Bool = false
    @Published var isCheckOut: Bool = false
    
    var punchInTimeStr: String?
    var punchOutTimeStr: String?
    
    @Published var workingHour: Double = 9
    @Published var workingHourStr: String?
    
    @Published var dateStr: String = { Date().toString(dateFormat: .yearMonthDate) }()
    @Published var weekDayStr: String = { Date().toString(dateFormat: .weekday) }()
    @Published var currentTimeStr: String = { Date().toString(dateFormat: .hourMinute) }()
    
    @Published var quoteSubject: String = "今天的語錄尚未抵達，不要著急，因為明天可能也到不了。"
    
    var captionLabel: UILabel = {
        let label = UILabel(frame: CGRect(x: 100, y: 100, width: 240, height: 30))
        label.text = "雙擊打卡開啟今天的工作"
        label.textColor = .black70
        return label
    }()
    
    var weatherIcon: UIImage = {
        return UIImage(named: "04")!
    }()
    
    var checkInButton: TimeButton = {
        let btn = TimeButton(frame: CGRect(x: 30, y: 0, width: 300, height: 100))
        btn.setImage(button: .work(state: .notPunchIn))
        return btn
    }()
    lazy var checkOutButton: TimeButton = {
        let btn = TimeButton(frame: CGRect(x: 30, y: 200, width: 300, height: 100))
        btn.setImage(button: .offWork(state: .notPunchOut))
        return btn
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

extension PunchClockViewModel {
    
    func createCheckInButton(controller: MainViewController, action: Selector) {
        $currentTimeStr
            .sink(receiveValue: { title in
                self.checkInButton.setTitle(string: title, button: .work(state: .notPunchIn))
            })
            .store(in: &cancellable)
        
        checkInButton.addTarget(controller, action: action, for: .touchDownRepeat)
        
        checkInButton.layoutButtonImage(at: .Left, spacing: 10)
        
        checkInButton.commonLayout(on: controller.view)
        checkInButton.topAnchor.constraint(equalTo: controller.view.safeAreaLayoutGuide.topAnchor).isActive = true
    }
    
    func createCheckOutButton(controller: MainViewController, action: Selector) {
        $currentTimeStr
            .sink(receiveValue: { title in
                self.checkOutButton.setTitle(string: title, button: .offWork(state: .notPunchOut))
            })
            .store(in: &cancellable)
        
        checkOutButton.addTarget(controller, action: action, for: .touchDownRepeat)
        
        checkOutButton.layoutButtonImage(at: .Left, spacing: 10)
        
        checkOutButton.commonLayout(on: controller.view)
        checkOutButton.topAnchor.constraint(equalTo: checkInButton.bottomAnchor, constant: 158).isActive = true
    }
}
