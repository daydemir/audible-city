//
//  BackgroundObservationManager.swift
//  Audible City
//
//  Created by Deniz Aydemir on 7/25/24.
//


import Foundation
import CoreLocation

class BackgroundObservationManager: NSObject, CLLocationManagerDelegate {
    private let locationManager: LocationManagerProtocol
    private let observationRecorder: ObservationRecorder
    private var currentTask: Task<Void, Never>?
    
    init(locationManager: LocationManagerProtocol, observationRecorder: ObservationRecorder) {
        self.locationManager = locationManager
        self.observationRecorder = observationRecorder
        super.init()
        
        self.locationManager.delegate = self
    }
    
    func start() {
        locationManager.requestAlwaysAuthorization()
        locationManager.startUpdatingLocation()
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }
        
        // Cancel any ongoing task
        currentTask?.cancel()
        
        // Start a new recording task
        currentTask = Task {
            await upload(observations: observationRecorder.startRecording(totalDuration: 60, segmentDuration: 5))
        }
    }
    
    private func upload(observations: AsyncStream<SoundObservation>) async {
        // Placeholder for upload functionality
        var batch: [SoundObservation] = []
        for await observation in observations {
            print("observation received")
            batch.append(observation)
            if (batch.count > 11) {
                print("Uploading \(batch.count) observations")
                batch.removeAll(keepingCapacity: true)
            }
        }
    }
}
