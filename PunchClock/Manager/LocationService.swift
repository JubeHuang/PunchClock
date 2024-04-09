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
    
    private let cityTWName: [String: String] = [
        "TPE": "臺北市",
        "KHH": "高雄市",
        "NWT": "新北市",
        "TNN": "臺南市",
        "TAO": "桃園市",
        "TXG": "臺中市",
        "ILA": "宜蘭縣",
        "HUA": "花蓮縣",
        "TTT": "臺東縣",
        "PEN": "澎湖縣",
        "KEE": "基隆市",
        "HSZ": "新竹市",
        "HSQ": "新竹縣",
        "CYI": "嘉義市",
        "CYQ": "嘉義縣",
        "KIN": "金門縣",
        "LIE": "連江縣",
        "MIA": "苗栗縣",
        "CHA": "彰化縣",
        "NAN": "南投縣",
        "YUN": "雲林縣",
        "PIF": "屏東縣"
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
               let cityName = self.transferToCH(administrativeArea) {
                completion(cityName)
            } else {
                print("No Place Mark")
            }
        }
    }
    
    private func transferToCH(_ abbr: String) -> String? {
        print(abbr, "縮寫")
        guard let cityName = cityTWName[abbr] else {
            print("====== Not Correspond With Taiwan City Name ======")
            return nil
        }
        return cityName
    }
}
