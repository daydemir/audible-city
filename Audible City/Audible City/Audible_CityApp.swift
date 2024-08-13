//
//  Audible_CityApp.swift
//  Audible City
//
//  Created by Deniz Aydemir on 7/19/24.
//

import SwiftUI
import SwiftData
import CoreLocation
import UserNotifications

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
    
    let locationManager = LocationManager()
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {

        locationManager.requestAlwaysAuthorization()
        locationManager.startUpdatingLocation()
        
        let audioProcessor = AudioProcessor()
        let observationRecorder = ObservationRecorder(locationManager: locationManager, audioProcessor: audioProcessor)
        
        backgroundObservationManager = BackgroundObservationManager(locationManager: locationManager, observationRecorder: observationRecorder)
        backgroundObservationManager?.start()
        
        return true
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

}
