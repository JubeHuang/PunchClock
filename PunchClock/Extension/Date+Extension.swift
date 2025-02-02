//
//  Date+Extension.swift
//  PunchClock
//
//  Created by Jube on 2023/7/12.
//

import Foundation.NSData

extension Date {
    
    func toString(dateFormat: DateFormat) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = dateFormat.rawValue
        
        return dateFormatter.string(from: self)
    }
}

enum DateFormat: String {
    
    case all = "yyyy/MM/dd HH:mm"
    case year = "yyyy"
    case hourMinute = "HH:mm"
    case yearMonthDate = "MMM / dd / yyyy"
    case weekday = "EEEE"
    case monthEn = "MMM"
    case monthInt = "MM"
    case date = "dd"
}
