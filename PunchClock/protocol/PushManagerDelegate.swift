//
//  PushManagerDelegate.swift
//  PunchClock
//
//  Created by Jube on 2024/4/7.
//

protocol PushManagerDelegate: AnyObject {
    func pushManagerDelegate(_ manager: PushManager, isOffWorkPushOn: Bool)
}
