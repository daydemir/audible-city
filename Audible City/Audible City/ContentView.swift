//
//  ContentView.swift
//  Audible City
//
//  Created by Deniz Aydemir on 7/19/24.
//

import SwiftUI

struct ContentView: View {
    let locationManager = LocationManager()
    let audioProcessor = AudioProcessor()
    
    var body: some View {
        TabView {
            LocationView(locationManager: locationManager)
                .tabItem {
                    Label("Location", systemImage: "location")
                }
            
            AudioRecordingView(audioProcessor: audioProcessor)
                .tabItem {
                    Label("Audio", systemImage: "waveform")
                }
            
            ObservationRecordingView(locationManager: locationManager, audioProcessor: audioProcessor)
                .tabItem {
                    Label("Observations", systemImage: "list.bullet.clipboard")
                }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
