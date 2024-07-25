//
//  LocationView.swift
//  Audible City
//
//  Created by Deniz Aydemir on 7/25/24.
//

import SwiftUI
import CoreLocation
import CoreMotion

struct LocationView<Manager: LocationManagerProtocol>: View {
    @State private var locationManager: Manager
    
    init(locationManager: Manager) {
        _locationManager = State(wrappedValue: locationManager)
    }
    
    var body: some View {
        VStack {
            Text("Location Permission")
                .font(.title)
            
            Button(action: {
                locationManager.requestAlwaysAuthorization()
            }) {
                Text("Request Always Location Permission")
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }
            
            Text("Current Status: \(authorizationStatusString)")
                .padding(.top)
            
            if locationManager.authorizationStatus == .authorizedAlways {
                Text("Current Location: \(locationString)")
                    .padding(.top)
                
                Text("Activity: \(activityString)")
                    .padding(.top)
            }
        }
    }
    
    private var authorizationStatusString: String {
        switch locationManager.authorizationStatus {
        case .notDetermined:
            return "Not Determined"
        case .restricted:
            return "Restricted"
        case .denied:
            return "Denied"
        case .authorizedAlways:
            return "Authorized Always"
        case .authorizedWhenInUse:
            return "Authorized When in Use"
        @unknown default:
            return "Unknown"
        }
    }
    
    private var locationString: String {
        guard let location = locationManager.location else { return "Unknown" }
        return "\(location.coordinate.latitude), \(location.coordinate.longitude)"
    }
    
    private var activityString: String {
        guard let activity = locationManager.currentActivity else { return "Unknown" }
        return "\(activity.typeString) (\(activity.confidence.string))"
    }
}

struct LocationView_Previews: PreviewProvider {
    static var previews: some View {
        LocationView(locationManager: MockLocationManager())
    }
}

class MockLocationManager: LocationManagerProtocol {
    weak var delegate: CLLocationManagerDelegate?
    var authorizationStatus: CLAuthorizationStatus = .authorizedAlways
    var location: CLLocation? = CLLocation(latitude: 37.7749, longitude: -122.4194)
    var currentActivity: CMMotionActivity?
    
    init() {
        let activity = CMMotionActivity()
//        activity.perform {
//            activity.cycling = true
//            activity.confidence = .high
//        }
        self.currentActivity = activity
    }
    
    func requestAlwaysAuthorization() {}
    func startUpdatingLocation() {}
    func stopUpdatingLocation() {}
}
