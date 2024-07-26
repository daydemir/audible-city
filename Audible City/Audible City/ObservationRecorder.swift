//
//  ObservationRecorder.swift
//  Audible City
//
//  Created by Deniz Aydemir on 7/25/24.
//

import Foundation
import CoreLocation
import AVFoundation
import CoreMotion

actor ObservationRecorder {
    private let locationManager: LocationManagerProtocol
    private let audioProcessor: AudioProcessorProtocol
    
    init(locationManager: LocationManagerProtocol, audioProcessor: AudioProcessorProtocol) {
        self.locationManager = locationManager
        self.audioProcessor = audioProcessor
    }
    
    func startRecording(totalDuration: TimeInterval, segmentDuration: TimeInterval) async -> AsyncStream<SoundObservation> {
        AsyncStream { continuation in
            Task {
                let startTime = Date()
                var elapsedTime: TimeInterval = 0
                
                while elapsedTime < totalDuration {
                    let segmentStart = Date()
                    
                    audioProcessor.startRecording()
                    try? await Task.sleep(for: .seconds(segmentDuration))
                    audioProcessor.stopRecording()
                    
                    if let observation = await createObservation(duration: segmentDuration) {
                        continuation.yield(observation)
                    }
                    
                    elapsedTime += Date().timeIntervalSince(segmentStart)
                }
                
                continuation.finish()
            }
        }
    }
    
    private func createObservation(duration: TimeInterval) async -> SoundObservation? {
        guard let location = locationManager.location,
              let activity = locationManager.currentActivity else {
            return nil
        }
        
        let locationStruct = Location(
            latitude: location.coordinate.latitude,
            longitude: location.coordinate.longitude,
            altitude: location.altitude
        )
        
        let activityStruct = Activity(
            type: activity.typeString,
            confidence: activity.confidence.string
        )
        
        return SoundObservation(
            id: UUID().uuidString,
            observer_id: getOrCreateDeviceID(),
            date: Date(),
            location: locationStruct,
            device: .iphone,
            loudness: Double(audioProcessor.currentDecibels),
            duration: duration,
            activity: activityStruct,
            classifications: audioProcessor.classifications,
            version: Bundle.main.buildVersionNumber ?? "unknown"
        )
    }
}

extension Bundle {
    var releaseVersionNumber: String? {
        return infoDictionary?["CFBundleShortVersionString"] as? String
    }
    var buildVersionNumber: String? {
        return infoDictionary?["CFBundleVersion"] as? String
    }
}

