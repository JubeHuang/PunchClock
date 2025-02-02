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
    
    private func requestAuthorization() {
        manager.requestWhenInUseAuthorization()
        manager.requestAlwaysAuthorization()
    }
}

extension LocationService: CLLocationManagerDelegate {
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        manager.stopUpdatingLocation()
        
        guard let location = locations.last else { return }
        
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
            manager.startUpdatingLocation()
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
                print("Location Transfer to City Error: \(error.localizedDescription)")
                return
            }
            
            if let placeMark = placemarks?.first,
               let administrativeArea = placeMark.administrativeArea,
               self.isInTaiwan(administrativeArea) {
                completion(administrativeArea)
            } else {
                print("No Place Mark")
                self.weatherService.weatherInfo.city = "不支援區"
            }
        }
    }
    
    private func isInTaiwan(_ abbr: String) -> Bool {
        print(abbr, "縮寫")
        guard cityTWName.contains(abbr) else {
            print("====== Not Correspond With Taiwan City Name ======")
            return false
        }
        return true
    }
}
