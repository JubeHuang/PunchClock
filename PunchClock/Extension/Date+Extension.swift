//
//  Date+Extension.swift
//  PunchClock
//
//  Created by Jube on 2023/7/12.
//

import Foundation.NSData

extension Date {
    
    func toString(dateFormat: String) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = dateFormat
        
        return dateFormatter.string(from: self)
    }
    
}

enum DateFormat: String {
    
    case all = "yyyy/MM/dd HH:mm"
    case hourMinute = "HH:mm"
    case yearMonthDate = "MMM / dd / yyyy"
    case weekday = "EEEE"
    case month = "MMM"
}
