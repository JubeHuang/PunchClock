//
//  Month.swift
//  PunchClock
//
//  Created by Jube on 2023/7/12.
//

enum Month: String, CaseIterable {
    case Jan
    case Feb
    case Mar
    case Apr
    case May
    case Jun
    case Jul
    case Aug
    case Sep
    case Oct
    case Nov
    case Dec
    
    var value: String {
        self.rawValue
    }
}
