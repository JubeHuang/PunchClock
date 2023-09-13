//
//  Wording.swift
//  PunchClock
//
//  Created by Jube on 2023/8/17.
//

enum Wording: String {
    
    case defaultQuote = "今天的語錄尚未抵達，不要著急，因為明天可能也到不了。"
    case caption = "雙擊打卡開啟今天的工作"
    
    var text: String {
        return self.rawValue
    }
}
