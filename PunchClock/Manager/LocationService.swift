//
//  LocationManager.swift
//  PunchClock
//
//  Created by Jube on 2023/7/19.
//

import CoreLocation
import MapKit

class LocationService: NSObject {
    
    static let shared = LocationService()
    private var manager = CLLocationManager()
    var weatherService = WeatherService()
    private var isUpdatingLocation = false
    private var isResolvingCity = false
    
    var updateCityHandler: ((String) -> Void)?
    
    private let cityTWName: [String] = [
        "臺北市",
        "高雄市",
        "新北市",
        "臺南市",
        "桃園市",
        "臺中市",
        "宜蘭縣",
        "花蓮縣",
        "臺東縣",
        "澎湖縣",
        "基隆市",
        "新竹市",
        "新竹縣",
        "嘉義市",
        "嘉義縣",
        "金門縣",
        "連江縣",
        "苗栗縣",
        "彰化縣",
        "南投縣",
        "雲林縣",
        "屏東縣"
    ]
    
    private override init() {}
}

extension LocationService {
    
    func loadLocation() {
        manager.delegate = self
        
        manager.desiredAccuracy = kCLLocationAccuracyBest
        
        requestAuthorization()
    }
    
    func refreshLocation() {
        switch manager.authorizationStatus {
        case .authorizedWhenInUse, .authorizedAlways:
            guard !isUpdatingLocation else { return }
            isUpdatingLocation = true
            manager.startUpdatingLocation()
        case .notDetermined:
            requestAuthorization()
        default:
            break
        }
    }
    
    private func requestAuthorization() {
        manager.requestWhenInUseAuthorization()
    }
}

extension LocationService: CLLocationManagerDelegate {
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard !isResolvingCity,
              let location = locations.last else { return }
        
        isResolvingCity = true
        isUpdatingLocation = false
        manager.stopUpdatingLocation()
        
        updateCityHandler = { city in
            self.weatherService.getWeatherState(city: city)
        }
        
        locationToCity(location, completion: updateCityHandler!)
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("====== Location Manager Error ======\nError: \(error)")
    }
    
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        switch manager.authorizationStatus {
            
        case .authorizedWhenInUse, .authorizedAlways:
            refreshLocation()
        case .notDetermined:
            requestAuthorization()
        case .restricted, .denied:
            print("location permission denied")
            
        default:
            break
        }
    }
    
    private func locationToCity(_ location: CLLocation, completion: @escaping (String) -> Void) {
        let geocoder = CLGeocoder()
        geocoder.reverseGeocodeLocation(location) { placemarks, error in
            if let error {
                self.isResolvingCity = false
                print("Location Transfer to City Error: \(error.localizedDescription)")
                return
            }
            
            if let placeMark = placemarks?.first,
               let administrativeArea = placeMark.administrativeArea,
               self.isInTaiwan(administrativeArea) {
                self.isResolvingCity = false
                completion(administrativeArea)
            } else {
                self.isResolvingCity = false
                print("No Place Mark")
                self.weatherService.weatherInfo.city = "不支援區"
            }
        }
    }
    
    private func isInTaiwan(_ abbr: String) -> Bool {
#if DEBUG
        print(abbr, "縮寫")
#endif
        guard cityTWName.contains(abbr) else {
            print("====== Not Correspond With Taiwan City Name ======")
            return false
        }
        return true
    }
}
