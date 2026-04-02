//
//  PushManager.swift
//  PunchClock
//
//  Created by Jube on 2023/8/14.
//

import UserNotifications
import UIKit

class PushManager {
    
    static let shared = PushManager()
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
        if suggestTime < now {
#if DEBUG
            print("====== PunchOut Push Skipped ======\nSuggest time is in the past: \(suggestTime)")
#endif
            return
        }
        
        let timeDifference = suggestTime.timeIntervalSince(now)
        let timeDifferenceInSeconds = Int(timeDifference)
        
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: Double(timeDifferenceInSeconds), repeats: false)
//        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 20, repeats: false)
        let request = UNNotificationRequest(identifier: "PunchOutPush", content: createPushContent(), trigger: trigger)
        
        UNUserNotificationCenter.current().add(request) { error in
            if let error {
                print("====== PunchOut Push Schedule Error ======\nError: \(error.localizedDescription)")
                return
            }
            
#if DEBUG
            print("====== PunchOut Push Scheduled ======\nSuggest time: \(suggestTime)\nInterval: \(timeDifferenceInSeconds)s")
            self.debugPrintPendingPunchOutPush()
#endif
        }
    }
    
    func removePunchOutPushNotification() {
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: ["PunchOutPush"])
#if DEBUG
        print("====== PunchOut Push Removed ======")
        debugPrintPendingPunchOutPush()
#endif
    }
    
    func enablePunchOutPush(on suggestTime: Date?, completion: @escaping (Bool) -> Void) {
        UNUserNotificationCenter.current()
            .getNotificationSettings { [weak self] settings in
                switch settings.authorizationStatus {
                    
                case .notDetermined:
                    self?.requestAuthorization { granted in
                        DispatchQueue.main.async {
                            if granted, let suggestTime {
                                self?.createPunchOutPushNotification(on: suggestTime)
                            } else if !granted {
                                print("not allowed")
                            }
                            completion(granted)
                        }
                    }
                case .authorized, .provisional, .ephemeral:
                    if let suggestTime {
                        self?.createPunchOutPushNotification(on: suggestTime)
                    }
                    DispatchQueue.main.async {
                        completion(true)
                    }
                case .denied:
                    DispatchQueue.main.async {
                        self?.openSettingPage()
                        completion(false)
                    }
                default:
                    DispatchQueue.main.async {
                        completion(false)
                    }
                }
            }
    }
    
    func syncStatus(completion: @escaping (Bool) -> Void) {
        UNUserNotificationCenter.current()
            .getNotificationSettings { settings in
                switch settings.authorizationStatus {
                    
                case .authorized, .provisional, .ephemeral:
                    DispatchQueue.main.async {
                        completion(true)
                    }
                default:
                    DispatchQueue.main.async {
                        completion(false)
                    }
                }
            }
    }
    
#if DEBUG
    private func debugPrintPendingPunchOutPush() {
        UNUserNotificationCenter.current().getPendingNotificationRequests { requests in
            let pushRequests = requests.filter { $0.identifier == "PunchOutPush" }
            
            if pushRequests.isEmpty {
                print("====== Pending PunchOut Push ======\nNo pending request")
                return
            }
            
            for request in pushRequests {
                if let trigger = request.trigger as? UNTimeIntervalNotificationTrigger {
                    print("====== Pending PunchOut Push ======\nIdentifier: \(request.identifier)\nTime interval: \(trigger.timeInterval)s\nRepeats: \(trigger.repeats)")
                } else {
                    print("====== Pending PunchOut Push ======\nIdentifier: \(request.identifier)\nTrigger: \(String(describing: request.trigger))")
                }
            }
        }
    }
#endif
}
