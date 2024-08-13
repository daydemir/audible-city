//
//  BackgroundObservationManager.swift
//  Audible City
//
//  Created by Deniz Aydemir on 7/25/24.
//

import CoreLocation
import Foundation
import Supabase
import UserNotifications

enum UserDefaultKey: String {
    case lastNotificationDateTimeInterval
}

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
        requestNotificationPermission()
    }

    func locationManager(
        _ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]
    ) {
        guard let _ = locations.last else { return }
        
        if let currentActivity = locationManager.currentActivity, currentActivity.walking {
            let lastNotifTime = UserDefaults().double(forKey: UserDefaultKey.lastNotificationDateTimeInterval.rawValue)
            if ((Date().timeIntervalSince(Date(timeIntervalSince1970: lastNotifTime))/60.0) > 30) {
                postImmediateNotification(title: "Activity Changed", body: "Now Walking")
            }
        }
        
        
        let recordingTime: TimeInterval = 10
        
        print("location update received, will start a \(recordingTime) second recording")

        if currentTask == nil {
            // Start a new recording task
            currentTask = Task {
                await upload(
                    observations: observationRecorder.startRecording(
                        totalDuration: recordingTime, segmentDuration: recordingTime))
            }
        }
    }
    
    func requestNotificationPermission() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
            if granted {
                print("Notification permission granted")
            } else {
                print("Notification permission denied")
            }
        }
    }
    
    private func postImmediateNotification(title: String, body: String) {
        let content = UNMutableNotificationContent()
        content.title = title
        content.body = body
        content.sound = .default

        let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: nil)
        
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Error posting notification: \(error)")
            } else {
                print("Notification posted successfully")
            }
        }
    }

    private func upload(observations: AsyncStream<(SoundObservation, [SoundClassification])>) async {
        // Placeholder for upload functionality
//        var batch: [SoundObservation] = []
        for await observation in observations {
            print("observation received")
            do {
                try await client.from("sound_observations")
                    .insert(observation.0.supabaseObject())
                    .execute()
                
                for classification in observation.1 {
                    try await client.from("sound_classifications")
                        .insert(classification.supabaseObject())
                        .execute()
                }
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

        let classificationsData = try JSONEncoder().encode(self.classifications)
        
        return SupabaseSoundObservation(
            id: self.id,
            observer_id: self.observer_id,
            observation_date: ISO8601DateFormatter().string(
                from: self.date
            ),
            location: self.location.postGIS,
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

extension SoundClassification {
    func supabaseObject() throws -> SupabaseSoundClassification {
        return SupabaseSoundClassification(
            id: self.id,
            observation_id: self.observation_id,
            observer_id: self.observer_id,
            observation_date: ISO8601DateFormatter().string(
                from: self.date
            ),
            location: self.location.postGIS,
            device: self.device.rawValue,
            loudness: self.loudness,
            duration: self.duration,
            activity_type: self.activity.type,
            activity_confidence: self.activity.confidence,
            label: self.label,
            confidence: self.confidence,
            version: self.version
        )
    }
}

extension Location {
    var postGIS: String {
        return "POINT(\(self.longitude) \(self.latitude) \(self.altitude ?? 0))"
    }
}

struct SupabaseSoundClassification: Codable {
    let id: String
    let observation_id: String
    
    let observer_id: String
    let observation_date: String
    let location: String
    let device: String
    let loudness: Double
    let duration: Double
    let activity_type: String
    let activity_confidence: String
    let label: String
    let confidence: Double
    let version: String
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
