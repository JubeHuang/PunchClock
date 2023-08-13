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
    
    private var timerSubscriber: AnyCancellable?
    private var cancellable = Set<AnyCancellable>()
    
    @Published var isPunchIn: Bool = false {
        didSet {
            if isPunchIn, punchInTime == nil {
                punchInTime = Date()
                UserDefaultManager.savePunchInTime(punchInTime!)
            } else if !isPunchIn {
                punchInTime = nil
            }
            
            captionLabel.isHidden = isPunchIn
            checkOutButton.isHidden = !isPunchIn
            checkInBtnState(isSelected: punchInTime != nil)
        }
    }
    lazy var punchInTime: Date? = nil
    var punchInTimeStr: String? { punchInTime?.toString(dateFormat: .hourMinute) }
    
    @Published var isPunchOut: Bool = false {
        didSet {
            switch isPunchOut {
            case true:
                punchOutTime = Date()
                
                UserDefaultManager.removePunchInTime()
                
                guard let month = punchInTime?.toString(dateFormat: .month) else { return }
                storeManager.createData(month: month, in: punchInTime, out: punchOutTime)
            case false:
                punchOutTime = nil
            }
            checkOutBtnState(isSelected: isPunchOut)
        }
    }
    lazy var punchOutTime: Date? = nil
    var punchOutTimeStr: String? { punchOutTime?.toString(dateFormat: .hourMinute) }
    
    
    @Published var workingHour: Double = 9
    @Published var workingHourStr: String?
    
    @Published var dateStr: String = { Date().toString(dateFormat: .yearMonthDate) }()
    @Published var weekDayStr: String = { Date().toString(dateFormat: .weekday) }()
    @Published var currentTimeStr: String = { Date().toString(dateFormat: .hourMinute) }()
    
    @Published var quoteSubject: String = "今天的語錄尚未抵達，不要著急，因為明天可能也到不了。"
    
    lazy var captionLabel: UILabel = {
        let label = UILabel(frame: CGRect(x: 100, y: 100, width: 240, height: 30))
        label.text = "雙擊打卡開啟今天的工作"
        label.textColor = .black70
        return label
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
        getTime()
        loadQuote()
        
        if let savedTime = UserDefaultManager.getPunchInTime() {
            punchInTime = savedTime
        }
        isPunchIn = punchInTime != nil
        
        bind()
    }
    
    deinit {
        timerSubscriber?.cancel()
    }
}

extension PunchClockViewModel {
    
    private func bind() {
        $workingHour
            .map { hours in
                let intHours = Int(hours * 10)
                guard intHours % 10 == 0 else { return "努力工作 \(hours) 小時" }
                return "努力工作 \(Int(hours)) 小時"
            }
            .assign(to: &$workingHourStr)
    }
    
    private func getTime() {
        timerSubscriber = Timer.publish(every: 1, on: .main, in: .default).autoconnect()
            .sink(receiveValue: { [weak self] currentTime in
                self?.currentTimeStr = currentTime.toString(dateFormat: .hourMinute)
            })
    }
    
    private func cancelTimer() {
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
            .sink(receiveValue: { [weak self] title in
                self?.checkInButton.setTitle(string: title, button: .work(state: .notPunchIn))
            })
            .store(in: &cancellable)
        
        checkInButton.addTarget(controller, action: action, for: .touchDownRepeat)
        
        checkInButton.layoutButtonImage(at: .Left, spacing: 10)
        
        checkInButton.commonLayout(on: controller.view)
        checkInButton.topAnchor.constraint(equalTo: controller.view.safeAreaLayoutGuide.topAnchor).isActive = true
    }
    
    func createCheckOutButton(controller: MainViewController, action: Selector) {
        $currentTimeStr
            .sink(receiveValue: { [weak self] title in
                self?.checkOutButton.setTitle(string: title, button: .offWork(state: .notPunchOut))
            })
            .store(in: &cancellable)
        
        checkOutButton.addTarget(controller, action: action, for: .touchDownRepeat)
        
        checkOutButton.layoutButtonImage(at: .Left, spacing: 10)
        
        checkOutButton.commonLayout(on: controller.view)
        checkOutButton.topAnchor.constraint(equalTo: checkInButton.bottomAnchor, constant: 158).isActive = true
    }
    
    private func checkInBtnState(isSelected: Bool) {
        checkInButton.isSelected = isSelected
        checkInButton.isUserInteractionEnabled = !isSelected
        
        if isSelected {
            checkInButton.setTitle(string: punchInTimeStr!, button: .work(state: .punchIn))
        }
    }
    
    private func checkOutBtnState(isSelected: Bool) {
        checkOutButton.isSelected = isSelected
        checkOutButton.isUserInteractionEnabled = !isSelected
        
        if isSelected {
            checkOutButton.setTitle(string: punchOutTimeStr!, button: .offWork(state: .punchOut))
        }
    }
    
    func vibrate(intensity: Int = 3) {
        let vibrateFeedback = UIImpactFeedbackGenerator(style: .medium)
        vibrateFeedback.prepare()
        vibrateFeedback.impactOccurred(intensity: 3)
    }
    
    func displayAlert(_ viewController: UIViewController, title: String? = nil, message: String? = nil, actionTitle: String = "YAY") {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let okAction = UIAlertAction(title: actionTitle, style: .default) { [weak self] _ in
            self?.isPunchIn = false
            self?.isPunchOut = false
        }
        alertController.addAction(okAction)
        
        viewController.present(alertController, animated: true)
    }
}
