//
//  PushManager.swift
//  PunchClock
//
//  Created by Jube on 2023/8/14.
//

import UserNotifications
import UIKit

protocol PushManagerDelegate: AnyObject {
    func pushManagerDelegate(_ controller: PushManager, isOffWorkPushOn: Bool)
}

class PushManager {
    
    static let shared = PushManager()
    weak var delegate: PushManagerDelegate?
    
    var isOffWorkPushOn = false
    
    private init() {}
    
    private func requestAuthorization(completion: @escaping (Bool) -> Void) {
        UNUserNotificationCenter.current()
            .requestAuthorization(options: [.alert, .badge, .sound]) { granted, error in
                if let error {
                    print("====== Push Request Auth Error ======\nError: \(error)")
                    completion(false)
                }
                
                completion(granted)
            }
    }
    
    private func openSettingPage() {
        if let settingsUrl = URL(string: UIApplication.openSettingsURLString) {
            UIApplication.shared.open(settingsUrl, options: [:], completionHandler: nil)
        }
    }
    
    private func createPushContent() -> UNMutableNotificationContent {
        let content = UNMutableNotificationContent()
        content.title = "叮咚～ 是不是該下班了～～～"
        content.body = "休息是為了讓明天更有動力，別忘了打下班卡呦！"
        content.sound = .default
        return content
    }
    
    func createPunchOutPushNotification(on suggestTime: Date) {
        let now = Date()
        if suggestTime < now { return }
        
        let timeDifference = suggestTime.timeIntervalSince(now)
        let timeDifferenceInSeconds = Int(timeDifference)
        
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: Double(timeDifferenceInSeconds), repeats: false)
//        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 20, repeats: false)
        let request = UNNotificationRequest(identifier: "PunchOutPush", content: createPushContent(), trigger: trigger)
        
        UNUserNotificationCenter.current().add(request)
    }
    
    func checkStatus(on suggestTime: Date) {
        UNUserNotificationCenter.current()
            .getNotificationSettings { [weak self] settings in
                switch settings.authorizationStatus {
                    
                case .notDetermined:
                    self?.requestAuthorization { granted in
                        if granted {
                            self?.createPunchOutPushNotification(on: suggestTime)
                        } else {
                            print("not allowed")
                            self?.delegate?.pushManagerDelegate(self!, isOffWorkPushOn: false)
                        }
                    }
                default:
                    DispatchQueue.main.async {
                        self?.openSettingPage()
                    }
                }
            }
    }
    
    func syncStatus() {
        UNUserNotificationCenter.current()
            .getNotificationSettings { [weak self] settings in
                switch settings.authorizationStatus {
                    
                case .denied:
                    self?.delegate?.pushManagerDelegate(self!, isOffWorkPushOn: false)
                case .authorized:
                    self?.delegate?.pushManagerDelegate(self!, isOffWorkPushOn: true)
                default:
                    break
                }
            }
    }
}
