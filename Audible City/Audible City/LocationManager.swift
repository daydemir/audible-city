//
//  LocationManager.swift
//  Audible City
//
//  Created by Deniz Aydemir on 7/25/24.
//

import CoreLocation
import Observation

protocol LocationManagerProtocol: Observable {
    var authorizationStatus: CLAuthorizationStatus? { get set }
    var lastLocation: CLLocation? { get }
    func requestAlwaysAuthorization()
    func startLocationUpdates()
    func stopLocationUpdates()
}

@Observable
class LocationManager: NSObject, LocationManagerProtocol, CLLocationManagerDelegate {
    private let locationManager = CLLocationManager()
    var authorizationStatus: CLAuthorizationStatus?
    var lastLocation: CLLocation?
    
    override init() {
        super.init()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters
        locationManager.allowsBackgroundLocationUpdates = true
        locationManager.pausesLocationUpdatesAutomatically = false
    }
    
    func requestAlwaysAuthorization() {
        locationManager.requestAlwaysAuthorization()
    }
    
    func startLocationUpdates() {
        locationManager.startUpdatingLocation()
        locationManager.startMonitoringSignificantLocationChanges()
    }
    
    func stopLocationUpdates() {
        locationManager.stopUpdatingLocation()
        locationManager.stopMonitoringSignificantLocationChanges()
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        lastLocation = locations.last
        // Here you would typically process the new location data
        print("New location: \(String(describing: lastLocation))")
    }
    
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        authorizationStatus = manager.authorizationStatus
    }
}
