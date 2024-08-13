//
//  ObservationRecorder.swift
//  Audible City
//
//  Created by Deniz Aydemir on 7/25/24.
//

import AVFoundation
import CoreLocation
import CoreMotion
import Foundation

actor ObservationRecorder {
    private let locationManager: LocationManagerProtocol
    private let audioProcessor: AudioProcessorProtocol

    init(
        locationManager: LocationManagerProtocol,
        audioProcessor: AudioProcessorProtocol
    ) {
        self.locationManager = locationManager
        self.audioProcessor = audioProcessor
    }

    func startRecording(
        totalDuration: TimeInterval, segmentDuration: TimeInterval
    ) async -> AsyncStream<(SoundObservation, [SoundClassification])> {
        AsyncStream { continuation in
            Task {
                var elapsedTime: TimeInterval = 0

                while elapsedTime < totalDuration {
                    let segmentStart = Date()

                    audioProcessor.startRecording()
                    try? await Task.sleep(for: .seconds(segmentDuration))
                    audioProcessor.stopRecording()

                    if let observation = await createObservation(
                        duration: segmentDuration)
                    {
                        continuation.yield(observation)
                    }

                    elapsedTime += Date().timeIntervalSince(segmentStart)
                }

                continuation.finish()
            }
        }
    }

    private func createObservation(duration: TimeInterval) async -> (
        SoundObservation, [SoundClassification]
    )? {
        guard let location = locationManager.location,
            let activity = locationManager.currentActivity
        else {
            return nil
        }

        let id = UUID().uuidString

        let locationStruct = Location(
            latitude: location.coordinate.latitude,
            longitude: location.coordinate.longitude,
            altitude: location.altitude
        )

        let activityStruct = Activity(
            type: activity.typeString,
            confidence: activity.confidence.string
        )
        
        let device: Device = .iphone
        
        let loudness = Double(audioProcessor.currentDecibels)
        
        let version = Bundle.main.buildVersionNumber ?? "unknown"

        let observerID = getOrCreateDeviceID()
        
        let date = Date()
        
        let observation = SoundObservation(
            id: id,
            observer_id: observerID,
            date: date,
            location: locationStruct,
            device: device,
            loudness: loudness,
            duration: duration,
            activity: activityStruct,
            classifications: audioProcessor.classifications,
            version: version
        )

        let classifications = audioProcessor.classifications
            .map {
                SoundClassification(
                    id: UUID().uuidString,
                    observer_id: observerID,
                    date: date,
                    location: locationStruct,
                    device: device,
                    version: version,
                    observation_id: id,
                    loudness: loudness,
                    duration: duration,
                    activity: activityStruct,
                    label: $0.label,
                    confidence: $0.confidence)
            }

        return (observation, classifications)
    }
}

extension Bundle {
    var releaseVersionNumber: String? {
        return infoDictionary?["CFBundleShortVersionString"] as? String
    }
    var buildVersionNumber: String? {
        return infoDictionary?["CFBundleVersion"] as? String
    }

    var fullVersion: String {
        return (releaseVersionNumber ?? "") + "." + (buildVersionNumber ?? "")
    }
}
