//
//  ContentView.swift
//  Audible City
//
//  Created by Deniz Aydemir on 7/19/24.
//

import SwiftUI
import CoreLocation

struct ContentView<Manager: LocationManagerProtocol>: View {
    @State private var locationManager: Manager
    
    init(locationManager: Manager) {
        _locationManager = State(initialValue: locationManager)
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
            
            Button(action: {
                locationManager.startLocationUpdates()
            }) {
                Text("Start Location Updates")
                    .padding()
                    .background(Color.green)
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }
            
            Button(action: {
                locationManager.stopLocationUpdates()
            }) {
                Text("Stop Location Updates")
                    .padding()
                    .background(Color.red)
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }
            
            if let location = locationManager.lastLocation {
                Text("Last Location: \(location.coordinate.latitude), \(location.coordinate.longitude)")
                    .padding(.top)
            }
        }
    }
    
    private var authorizationStatusString: String {
        guard let status = locationManager.authorizationStatus else {
            return "Unknown"
        }
        
        switch status {
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
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            ContentView(locationManager: MockLocationManager(status: .notDetermined))
                .previewDisplayName("Not Determined")
            
            ContentView(locationManager: MockLocationManager(status: .authorizedAlways))
                .previewDisplayName("Authorized Always")
            
            ContentView(locationManager: MockLocationManager(status: .denied))
                .previewDisplayName("Denied")
        }
    }
}

@Observable
class MockLocationManager: LocationManagerProtocol {
    var authorizationStatus: CLAuthorizationStatus?
    var lastLocation: CLLocation?
    
    init(status: CLAuthorizationStatus) {
        self.authorizationStatus = status
    }
    
    func requestAlwaysAuthorization() {
        // Do nothing in mock implementation
    }
    
    func startLocationUpdates() {
        // Simulate location updates in mock
        print("Mock: Started location updates")
    }
    
    func stopLocationUpdates() {
        // Simulate stopping location updates in mock
        print("Mock: Stopped location updates")
    }
}
