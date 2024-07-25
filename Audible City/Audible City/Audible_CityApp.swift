//
//  Audible_CityApp.swift
//  Audible City
//
//  Created by Deniz Aydemir on 7/19/24.
//

import SwiftUI
import SwiftData
import CoreLocation

@main
struct AudibleCityApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}

class AppDelegate: NSObject, UIApplicationDelegate {
    var backgroundObservationManager: BackgroundObservationManager?
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        let locationManager = LocationManager()
        let audioProcessor = AudioProcessor()
        let observationRecorder = ObservationRecorder(locationManager: locationManager, audioProcessor: audioProcessor)
        
        backgroundObservationManager = BackgroundObservationManager(locationManager: locationManager, observationRecorder: observationRecorder)
        backgroundObservationManager?.start()
        
        return true
    }
}
