//
//  WeatherRequest.swift
//  PunchClock
//
//  Created by Jube on 2023/8/17.
//
import Foundation

struct WeatherRequest {
    
    var authorization: String?
    
    var cityName: String?
    var limit: String?
    var elementName: String?
    var sort: String?
    
    init(cityName: String? = nil) {
        self.authorization = "CWB-91AF46FD-294C-453A-8363-4962BF37A16B"
        self.cityName = cityName
        self.limit = "2"
        self.elementName = "Wx"
        self.sort = "time"
    }
}

extension WeatherRequest: Codable {
    
    enum CodingKeys: String, CodingKey {
        case authorization = "Authorization"
        case cityName = "locationName"
        case limit
        case elementName
        case sort
    }
}
