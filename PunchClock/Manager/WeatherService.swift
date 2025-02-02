//
//  WeatherService.swift
//  PunchClock
//
//  Created by Jube on 2023/8/10.
//

import Combine
import Foundation

class WeatherService {
    
    private var apiUrl: URL {
        let urlString = (Bundle.main.object(forInfoDictionaryKey: "weatherAPI") as? String)?.replacingOccurrences(of: "\\", with: "")
        return URL(string: urlString ?? "")!
    }
    private var storeSession: [String: AnyCancellable] = [:]
    @Published var weatherInfo: (city: String, iconName: String) = ("定位中", "4")
    
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
                self.storeSession.removeValue(forKey: "session")
            } receiveValue: { data in
                self.parseWeatherData(data)
            }

        storeSession["session"] = session
    }
}

extension WeatherService {
    
    private func createUrl(city: String) -> URL? {
        let param = WeatherRequest(cityName: city)
        return apiUrl.add(param: param)
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
            let weather = try JSONDecoder().decode(WeatherResponse.self, from: data)
            let location = weather.records.location
            
            if location.count > 0 {
                let parameterValue = location[0].weatherElement[0].time[0].parameter.parameterValue
                let cityName = location[0].locationName
                
                weatherInfo = (city: cityName, iconName: parameterValue)
                print(weatherInfo)
            }
        } catch {
            print("====== Weather API Decode Error ======\nError: \(error.localizedDescription)")
        }
    }
}
