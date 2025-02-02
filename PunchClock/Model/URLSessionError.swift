//
//  URLError.swift
//  PunchClock
//
//  Created by Jube on 2023/8/10.
//

import Foundation

enum URLSessionError: Error {
    case badHttpResponse(statusCode: Int)
    
    var description: String {
        switch self {
            
        case .badHttpResponse(let statusCode):
            return "Bad Server Response [Code] \(statusCode)"
        }
    }
}
