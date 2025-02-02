//
//  weather.swift
//  PunchClock
//
//  Created by Jube on 2023/8/10.
//

struct WeatherResponse: Codable {
    let records: Records
}

// MARK: - Records
struct Records: Codable {
    let location: [Location]
}

// MARK: - Location
struct Location: Codable {
    let locationName: String
    let weatherElement: [WeatherElement]
}

// MARK: - WeatherElement
struct WeatherElement: Codable {
    let time: [Time]
}

// MARK: - Time
struct Time: Codable {
    let startTime, endTime: String
    let parameter: Parameter
}

// MARK: - Parameter
struct Parameter: Codable {
    let parameterName, parameterValue: String
}
