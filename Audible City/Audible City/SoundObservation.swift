//
//  Observation.swift
//  Audible City
//
//  Created by Deniz Aydemir on 7/25/24.
//

import Foundation

struct Location: Codable {
    let latitude: Double
    let longitude: Double
    let altitude: Double?
}

struct SoundObservation: Codable {
    let observer_id: String
    let date: Date
    let location: Location
    let device: Device
    
    let loudness: Double
    let duration: TimeInterval
    let activity: Activity
    let classifications: [Classification]
}

enum Device: String, Codable {
    case iphone
    case watch
}

struct Activity: Codable {
    let type: String
    let confidence: String
}

struct Classification: Codable {
    let label: String
    let confidence: Double
}

extension Classification {
    var description: String {
        return label + ": \(confidence)"
    }
}


func getOrCreateDeviceID() -> String {
    let key = "UniqueDeviceID"
    if let existingID = UserDefaults.standard.string(forKey: key) {
        return existingID
    } else {
        let newID = UUID().uuidString
        UserDefaults.standard.set(newID, forKey: key)
        return newID
    }
}


