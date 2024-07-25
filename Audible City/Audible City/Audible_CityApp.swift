//
//  Audible_CityApp.swift
//  Audible City
//
//  Created by Deniz Aydemir on 7/19/24.
//

import SwiftUI
import SwiftData

@main
struct Audible_CityApp: App {

    @State private var locationManager = LocationManager()
        @State private var audioProcessor = AudioProcessor()
        
        var body: some Scene {
            WindowGroup {
                TabView {
                    ContentView(locationManager: locationManager)
                        .tabItem {
                            Label("Location", systemImage: "location")
                        }
                    
                    AudioRecordingView(audioProcessor: audioProcessor)
                        .tabItem {
                            Label("Audio", systemImage: "waveform")
                        }
                }
            }
        }}
