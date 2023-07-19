//
//  LocationManager.swift
//  PunchClock
//
//  Created by Jube on 2023/7/19.
//

import CoreLocation
import MapKit

class LocationService: NSObject {
    
    var manager = CLLocationManager()
    
    var updateCityHandler: ((String) -> Void)?
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
        guard let location = locations.last else { return }
        
        updateCityHandler = { city in
            
        }
        
        locationToCity(location, completion: updateCityHandler!)
    }
    
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        switch manager.authorizationStatus {
            
        case .notDetermined:
            requestAuthorization()
        case .restricted, .denied:
            print("location permission denied")
            
        default:
            break
        }
    }
    
    func locationToCity(_ location: CLLocation, completion: @escaping (String) -> Void) {
        let geocoder = CLGeocoder()
        var city = ""
        
        geocoder.reverseGeocodeLocation(location) { placemarks, error in
            
            if let error {
                print("Location Transfer to City Error: \(error.localizedDescription)")
                completion("")
                return
            }
            
            if let placeMark = placemarks?.first {
                if let administrativeArea = placeMark.administrativeArea {
                    completion(administrativeArea)
                }
            } else {
                completion("")
            }
        }
    }
}
