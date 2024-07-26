//
//  BackgroundObservationManager.swift
//  Audible City
//
//  Created by Deniz Aydemir on 7/25/24.
//

import CoreLocation
import Foundation
import Supabase

class BackgroundObservationManager: NSObject, CLLocationManagerDelegate {
    private let locationManager: LocationManagerProtocol
    private let observationRecorder: ObservationRecorder
    private var currentTask: Task<Void, Never>?

    init(
        locationManager: LocationManagerProtocol,
        observationRecorder: ObservationRecorder
    ) {
        self.locationManager = locationManager
        self.observationRecorder = observationRecorder
        super.init()

        self.locationManager.delegate = self
    }

    func start() {
        locationManager.requestAlwaysAuthorization()
        locationManager.startUpdatingLocation()
    }

    func locationManager(
        _ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]
    ) {
        guard let _ = locations.last else { return }
        
        print("location update received, will start a 60 second recording")

        // Cancel any ongoing task
        currentTask?.cancel()

        // Start a new recording task
        currentTask = Task {
            await upload(
                observations: observationRecorder.startRecording(
                    totalDuration: 60, segmentDuration: 5))
        }
    }

    private func upload(observations: AsyncStream<SoundObservation>) async {
        // Placeholder for upload functionality
//        var batch: [SoundObservation] = []
        for await observation in observations {
            print("observation received")
            do {
                try await client.from("sound_observations")
                    .insert(observation.supabaseObject())
                    .execute()
            } catch {
                print("error uploading: \(error.localizedDescription)")
            }

            //            batch.append(observation)
            //            if (batch.count > 4) {
            //                try! await Database.batchWrite(toTable: "sound-observations", items: batch)
            //                print("Uploading \(batch.count) observations")
            //                batch.removeAll(keepingCapacity: true)
            //            }
        }
    }
}

extension SoundObservation {

    func supabaseObject() throws -> SupabaseSoundObservation {
        let locationPoint =
            "POINT(\(self.location.longitude) \(self.location.latitude) \(self.location.altitude ?? 0))"

        let classificationsData = try JSONEncoder().encode(self.classifications)
        
        return SupabaseSoundObservation(
            id: self.id,
            observer_id: self.observer_id,
            observation_date: ISO8601DateFormatter().string(
                from: self.date
            ),
            location: locationPoint,
            device: self.device.rawValue,
            loudness: self.loudness,
            duration: self.duration,
            activity_type: self.activity.type,
            activity_confidence: self.activity.confidence,
            classifications: classificationsData,
            classifications_text: String(data: classificationsData, encoding: .utf8)!,
            version: self.version
        )
    }
}

struct SupabaseSoundObservation: Codable {
    let id: String
    let observer_id: String
    let observation_date: String
    let location: String
    let device: String
    let loudness: Double
    let duration: Double
    let activity_type: String
    let activity_confidence: String
    let classifications: Data
    let classifications_text: String
    let version: String
}
