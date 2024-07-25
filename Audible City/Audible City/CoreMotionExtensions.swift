//
//  CoreMotionExtensions.swift
//  Audible City
//
//  Created by Deniz Aydemir on 7/25/24.
//

import CoreMotion

extension CMMotionActivity {
    var typeString: String {
        if stationary { return "stationary" }
        if walking { return "walking" }
        if running { return "running" }
        if automotive { return "driving" }
        if cycling { return "cycling" }
        return "unknown"
    }
}

extension CMMotionActivityConfidence {
    var string: String {
        switch self {
        case .low: return "low"
        case .medium: return "medium"
        case .high: return "high"
        @unknown default: return "unknown"
        }
    }
}
