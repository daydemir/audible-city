//
//  ObservationRecordingView.swift
//  Audible City
//
//  Created by Deniz Aydemir on 7/25/24.
//


import SwiftUI

import SwiftUI

struct ObservationRecordingView: View {
    @State private var totalDuration: TimeInterval = 60
    @State private var segmentDuration: TimeInterval = 5
    @State private var observations: [SoundObservation] = []
    @State private var isRecording = false
    
    let locationManager: LocationManagerProtocol
    let audioProcessor: AudioProcessorProtocol
    
    var body: some View {
        VStack {
            Form {
                Section(header: Text("Recording Settings")) {
                    Stepper("Total Duration: \(Int(totalDuration))s", value: $totalDuration, in: 10...300, step: 10)
                    Stepper("Segment Duration: \(Int(segmentDuration))s", value: $segmentDuration, in: 1...30, step: 1)
                }
                
                Section {
                    Button(action: startRecording) {
                        Text(isRecording ? "Recording..." : "Start Recording")
                    }
                    .disabled(isRecording)
                }
            }
            
            List(observations, id: \.date) { observation in
                VStack(alignment: .leading) {
                    Text("Date: \(observation.date)")
                    Text("Location: \(observation.location.latitude), \(observation.location.longitude)")
                    Text("Loudness: \(observation.loudness) dB")
                    Text("Activity: \(observation.activity.type) (\(observation.activity.confidence))")
                    Text("Classifications:")
                    ForEach(observation.classifications, id: \.label) { classification in
                        Text("- \(classification.label): \(classification.confidence)")
                    }
                }
                .padding(.vertical, 5)
            }
        }
    }
    
    private func startRecording() {
        guard !isRecording else { return }
        
        isRecording = true
        observations.removeAll()
        
        Task {
            let recorder = ObservationRecorder(locationManager: locationManager, audioProcessor: audioProcessor)
            
            for await observation in await recorder.startRecording(totalDuration: totalDuration, segmentDuration: segmentDuration) {
                await MainActor.run {
                    observations.append(observation)
                }
            }
            
            await MainActor.run {
                isRecording = false
            }
        }
    }
}

struct ObservationRecordingView_Previews: PreviewProvider {
    static var previews: some View {
        ObservationRecordingView(
            locationManager: MockLocationManager(),
            audioProcessor: MockAudioProcessor()
        )
    }
}
