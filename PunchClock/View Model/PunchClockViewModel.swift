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
    
    private let firestoreManager = FirestoreManager()
    
    private var timerSubscriber: AnyCancellable?
    private var cancellable = Set<AnyCancellable>()
    
    weak var weatherService = LocationService.shared.weatherService
    private weak var pushManager = PushManager.shared
    
    lazy var isOffWorkPushOn = false {
        didSet {
            if isOffWorkPushOn {
                createPush()
            }
        }
    }
    
    @Published var isPunchIn: Bool = false {
        didSet {
            if isPunchIn, punchInTime == nil {
                punchInTime = Date()
                UserDefaultManager.savePunchInTime(punchInTime!)
                
                getSuggestTimeStr()
            } else if !isPunchIn {
                punchInTime = nil
            }
            
            shouldUIHidden(isPunchIn)
            checkInBtnState(isSelected: punchInTime != nil)
        }
    }
    lazy var punchInTime: Date? = nil
    var punchInTimeStr: String? { punchInTime?.toString(dateFormat: .hourMinute) }
    
    @Published var isPunchOut: Bool = false {
        didSet {
            switch isPunchOut {
            case true:
                if isAutoPunchOut(), let savedOutTime = UserDefaultManager.getPunchOutTime() {
                    punchOutTime = savedOutTime
                    resetData()
                } else {
                    punchOutTime = Date()
                }
                
                UserDefaultManager.removeAllPunchTime()
                
                guard let month = punchInTime?.toString(dateFormat: .monthEn),
                      let year = punchInTime?.toString(dateFormat: .year) else { return }
                firestoreManager.createData(in: (month, year), in: punchInTime, out: punchOutTime)
            case false:
                punchOutTime = nil
            }
            checkOutBtnState(isSelected: isPunchOut)
        }
    }
    lazy var punchOutTime: Date? = nil
    var punchOutTimeStr: String? { punchOutTime?.toString(dateFormat: .hourMinute) }
    
    private var workingHour: Double {
        UserDefaultManager.getWorkingHours() > 0 ?  UserDefaultManager.getWorkingHours() : 9.0
    }
    var workingHourStr: String {
        isHoursInt ? "努力工作 \(Int(workingHour)) 小時" : "努力工作 \(workingHour) 小時"
    }
    
    @Published var dateStr: String = { Date().toString(dateFormat: .yearMonthDate) }()
    @Published var weekDayStr: String = { Date().toString(dateFormat: .weekday) }()
    @Published var currentTimeStr: String = { Date().toString(dateFormat: .hourMinute) }()
    
    @Published var quoteStr: String = Wording.defaultQuote.text
    
    lazy var captionLabel: UILabel = {
        let label = UILabel(frame: CGRect(x: 100, y: 100, width: 240, height: 30))
        label.text = Wording.caption.text
        label.textColor = .black70
        return label
    }()
    
    lazy var suggestTimeLabel: UILabel = {
        let label = UILabel(frame: CGRect(x: 100, y: 100, width: 240, height: 30))
        label.textColor = .black70
        return label
    }()
    private var suggestTime: Date? {
        guard let punchInTime else { return nil }
        return getSuggestTime(from: punchInTime)
    }
    
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
    
    let imageSpacing: CGFloat = 10
    var isHoursInt: Bool { Int(workingHour * 10) % 10 == 0 }
    
    init() {
        getCurrentTime()
        getPunchInStateAndTime()
        loadQuote()
        
        pushManager?.delegate = self
    }
    
    deinit {
        timerSubscriber?.cancel()
    }
}

extension PunchClockViewModel {
    
    private func getPunchInStateAndTime() {
        if let savedTime = UserDefaultManager.getPunchInTime() {
            self.punchInTime = savedTime
        }
        self.isPunchIn = self.punchInTime != nil
    }
    
    private func createPush() {
        guard let suggestTime else { return }
        pushManager?.createPunchOutPushNotification(on: suggestTime)
    }
    
    private func getSuggestTime(from punchIn: Date) -> Date {
        let seconds = workingHour * 60 * 60
        return punchIn.addingTimeInterval(seconds)
    }
    
    private func getCurrentTime() {
        timerSubscriber = Timer.publish(every: 1, on: .main, in: .default).autoconnect()
            .sink(receiveValue: { [weak self] currentTime in
                self?.currentTimeStr = currentTime.toString(dateFormat: .hourMinute)
            })
    }
    
    private func cancelTimer() {
        self.timerSubscriber?.cancel()
    }
    
    private func checkInBtnState(isSelected: Bool) {
        checkInButton.isSelected = isSelected
        checkInButton.isUserInteractionEnabled = !isSelected
        
        if isSelected {
            checkInButton.setTitle(string: punchInTimeStr!, button: .work(state: .punchIn))
        }
    }
    
    private func isAutoPunchOut() -> Bool {
        if let outTime = UserDefaultManager.getPunchOutTime() {
            return UserDefaultManager.getAutoPunchOutState() && outTime <= Date()
        }
        return false
    }
    
    private func checkOutBtnState(isSelected: Bool) {
        checkOutButton.isSelected = isSelected
        checkOutButton.isUserInteractionEnabled = !isSelected
        
        if isSelected {
            checkOutButton.setTitle(string: punchOutTimeStr!, button: .offWork(state: .punchOut))
        }
    }
    
    private func shouldUIHidden(_ isHidden: Bool) {
        captionLabel.isHidden = isHidden
        suggestTimeLabel.isHidden = !isHidden
        checkOutButton.isHidden = !isHidden
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
        
        checkInButton.layoutButtonImage(at: .Left, spacing: imageSpacing)
        
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
        
        checkOutButton.layoutButtonImage(at: .Left, spacing: imageSpacing)
        
        checkOutButton.commonLayout(on: controller.view)
        checkOutButton.topAnchor.constraint(equalTo: checkInButton.bottomAnchor, constant: 158).isActive = true
    }
    
    func getSuggestTimeStr() {
        guard let suggestTime else { return }
        suggestTimeLabel.text = "不加班的Me要 " + suggestTime.toString(dateFormat: .hourMinute) + " 下班"
    }
    
    func loadQuote() {
        firestoreManager.getQuote { [weak self] quote in
            self?.quoteStr = quote
        }
    }
    
    func checkAutoPunchOut() {
        if isAutoPunchOut() {
            self.isPunchOut = true
        }
    }
    
    func resetData() {
        isPunchIn = false
        isPunchOut = false
    }
    
    func vibrate(intensity: Int = 3) {
        let vibrateFeedback = UIImpactFeedbackGenerator(style: .medium)
        vibrateFeedback.prepare()
        vibrateFeedback.impactOccurred(intensity: 3)
    }
}

extension PunchClockViewModel: PushManagerDelegate {
    func pushManagerDelegate(_ manager: PushManager, isOffWorkPushOn: Bool) {
        self.isOffWorkPushOn = isOffWorkPushOn
    }
}
