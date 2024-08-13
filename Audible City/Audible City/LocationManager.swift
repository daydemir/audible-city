//
//  LocationManager.swift
//  Audible City
//
//  Created by Deniz Aydemir on 7/25/24.
//

import CoreLocation
import CoreMotion

protocol LocationManagerProtocol: AnyObject {
    var delegate: CLLocationManagerDelegate? { get set }
    var authorizationStatus: CLAuthorizationStatus { get }
    var location: CLLocation? { get }
    var currentActivity: CMMotionActivity? { get }
    
    func requestAlwaysAuthorization()
    func startUpdatingLocation()
    func stopUpdatingLocation()
}

class LocationManager: NSObject, LocationManagerProtocol, CLLocationManagerDelegate {
    private let manager: CLLocationManager
    private let activityManager: CMMotionActivityManager
    
    var delegate: CLLocationManagerDelegate? {
        get { manager.delegate }
        set { manager.delegate = newValue }
    }
    
    var authorizationStatus: CLAuthorizationStatus {
        manager.authorizationStatus
    }
    
    var location: CLLocation? {
        manager.location
    }
    
    @Published var currentActivity: CMMotionActivity?
    
    init(manager: CLLocationManager = CLLocationManager(), activityManager: CMMotionActivityManager = CMMotionActivityManager()) {
        self.manager = manager
        self.activityManager = activityManager
        super.init()
        
        self.manager.delegate = self
        self.manager.desiredAccuracy = kCLLocationAccuracyBest
        self.manager.distanceFilter = 10
        self.manager.allowsBackgroundLocationUpdates = true
        self.manager.pausesLocationUpdatesAutomatically = false
        
        startActivityUpdates()
    }
    
    func requestAlwaysAuthorization() {
        manager.requestAlwaysAuthorization()
    }
    
    func startUpdatingLocation() {
        manager.startUpdatingLocation()
        manager.startMonitoringSignificantLocationChanges()

    }
    
    func stopUpdatingLocation() {
        manager.stopUpdatingLocation()
    }
    
    private func startActivityUpdates() {
        if CMMotionActivityManager.isActivityAvailable() {
            activityManager.startActivityUpdates(to: OperationQueue.main) { [weak self] activity in
                self?.currentActivity = activity
            }
        }
    }
    
    // Implement other CLLocationManagerDelegate methods as needed
}
