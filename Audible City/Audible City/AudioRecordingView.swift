//
//  AudioRecordingView.swift
//  Audible City
//
//  Created by Deniz Aydemir on 7/25/24.
//


import SwiftUI
import AVFAudio

struct AudioRecordingView<Processor: AudioProcessorProtocol>: View {
    @State private var audioProcessor: Processor
    
    init(audioProcessor: Processor) {
        _audioProcessor = State(initialValue: audioProcessor)
    }
    
    var body: some View {
        VStack {
            Text("Audio Recording")
                .font(.title)
            
            Button(action: {
                if audioProcessor.isRecording {
                    audioProcessor.stopRecording()
                } else {
                    audioProcessor.startRecording()
                }
            }) {
                Text(audioProcessor.isRecording ? "Stop Recording" : "Start Recording")
                    .padding()
                    .background(audioProcessor.isRecording ? Color.red : Color.green)
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }
            
            if audioProcessor.isRecording {
                Text("Current Volume: \(String(format: "%.2f", audioProcessor.currentDecibels)) dB")
                    .padding()
            }
            
            List(audioProcessor.classifications, id: \.label) { classification in
                Text(classification.description)
            }
        }
    }
}

struct AudioRecordingView_Previews: PreviewProvider {
    static var previews: some View {
        AudioRecordingView(audioProcessor: MockAudioProcessor())
    }
}

class MockAudioProcessor: AudioProcessorProtocol {
    
    
    var isRecording: Bool = false
    var classifications: [Classification] = [Classification(label: "Dog", confidence: 0.8), Classification(label: "Cat", confidence: 0.5)]
    var currentDecibels: Float = -30.0
    
    func startRecording() { isRecording = true }
    func stopRecording() { isRecording = false }
}
