//
//  WeatherService.swift
//  PunchClock
//
//  Created by Jube on 2023/8/10.
//

import Combine
import Foundation

class WeatherService {
    
    private let apiUrl = URL(string: "https://opendata.cwb.gov.tw/api/v1/rest/datastore/F-C0032-001")!
    private let authorization = "CWB-91AF46FD-294C-453A-8363-4962BF37A16B"
    
    private var storeDictionary: [String: AnyCancellable] = [:]
    
    @Published var iconName: String = "04"
    @Published var cityName: String = ""
    
    func getWeatherState(city: String) {
        guard let url = createUrl(city: city) else {
            print("urlComponent error")
            return
        }
        
        let session = URLSession.shared.dataTaskPublisher(for: url)
            .tryMap { data, response in
                try self.checkHTTPError(response)
                return data
            }.sink { completion in
                if case .failure(let error) = completion {
                    self.handleUrlSessionError(error)
                }
                self.storeDictionary.removeValue(forKey: "session")
            } receiveValue: { data in
                
            }

        storeDictionary["session"] = session
    }
    
    
}

extension WeatherService {
    
    private func createUrl(city: String) -> URL? {
        var urlComponent = URLComponents(url: apiUrl, resolvingAgainstBaseURL: true)
        let query: [String : String] = [
            "Authorization": authorization,
            "limit": "2",
            "locationName": city,
            "elementName": "Wx",
            "sort": "time"
        ]
        urlComponent?.queryItems = query.map({ URLQueryItem(name: $0.key, value: $0.value) })
        
        return urlComponent?.url
    }
    
    private func handleUrlSessionError(_ error: Error) {
        if let err = error as? URLSessionError {
            print("====== Weather API Error ======\nError: \(err.description)")
        }
        print("====== Weather API Error ======\nError: \(error.localizedDescription)")
    }
    
    private func checkHTTPError(_ response: URLResponse) throws {
        if let httpResponse = response as? HTTPURLResponse,
           httpResponse.statusCode != 200 {
            throw URLSessionError.badHttpResponse(statusCode: httpResponse.statusCode)
        }
    }
    
    private func parseWeatherData(_ data: Data) {
        do {
            let weather = try JSONDecoder().decode(Weather.self, from: data)
            let location = weather.records.location
            
            if location.count > 0 {
                let parameterValue = location[0].weatherElement[0].time[0].parameter.parameterValue
                let cityName = location[0].locationName
                
                self.iconName = parameterValue
                self.cityName = cityName
            }
            
            
        } catch {
            print("====== Weather API Decode Error ======\nError: \(error.localizedDescription)")
        }
    }
}
