//
//  AudioProcessor.swift
//  Audible City
//
//  Created by Deniz Aydemir on 7/25/24.
//
import Foundation
import AVFoundation
import Combine
import SoundAnalysis

protocol AudioProcessorProtocol {
    var isRecording: Bool { get }
    var classifications: [Classification] { get }
    var currentDecibels: Float { get }
    func startRecording()
    func stopRecording()
}

class DecibelExtractor {
    func installTap(on node: AVAudioNode, bus: AVAudioNodeBus, bufferSize: AVAudioFrameCount) -> PassthroughSubject<Float, Never> {
        let subject = PassthroughSubject<Float, Never>()
        
        node.installTap(onBus: bus, bufferSize: bufferSize, format: nil) { buffer, _ in
            let level = self.calculateDecibels(buffer)
            subject.send(level)
        }
        
        return subject
    }
    
    private func calculateDecibels(_ buffer: AVAudioPCMBuffer) -> Float {
        guard let channelData = buffer.floatChannelData?[0] else { return -160.0 }
        let channelDataArray = Array(UnsafeBufferPointer(start: channelData, count: Int(buffer.frameLength)))
        let rms = sqrt(channelDataArray.map { $0 * $0 }.reduce(0, +) / Float(buffer.frameLength))
        return 20 * log10(rms)
    }
}

@Observable
class AudioProcessor: AudioProcessorProtocol {
    private var classifier: SystemAudioClassifier
    private var classificationSubject: PassthroughSubject<SNClassificationResult, Error>?
    private var cancellable: AnyCancellable?
    private var decibelExtractor: DecibelExtractor
    private var decibelCancellable: AnyCancellable?
    private var audioEngine: AVAudioEngine?
    
    var isRecording: Bool = false
    var classifications: [Classification] = []
    var currentDecibels: Float = -160.0
    
    init(classifier: SystemAudioClassifier = .singleton, decibelExtractor: DecibelExtractor = DecibelExtractor()) {
        self.classifier = classifier
        self.decibelExtractor = decibelExtractor
    }
    
    func startRecording() {
        guard !isRecording else { return }
        
        do {
            try setupAudioSession()
            try setupAudioEngine()
            
            classificationSubject = PassthroughSubject<SNClassificationResult, Error>()
            
            cancellable = classificationSubject?
                .receive(on: DispatchQueue.main)
                .sink(
                    receiveCompletion: { [weak self] completion in
                        self?.isRecording = false
                        switch completion {
                        case .finished:
                            print("Classification finished")
                        case .failure(let error):
                            print("Classification failed with error: \(error)")
                        }
                    },
                    receiveValue: { [weak self] result in
                        self?.handleClassificationResult(result)
                    }
                )
            
            let inferenceWindowSize = 5.0
            let overlapFactor = 0.5
            
            classifier.startSoundClassification(
                subject: classificationSubject!,
                inferenceWindowSize: inferenceWindowSize,
                overlapFactor: overlapFactor
            )
            
            try audioEngine?.start()
            isRecording = true
        } catch {
            print("Failed to start recording: \(error)")
        }
    }
    
    func stopRecording() {
        guard isRecording else { return }
        
        classifier.stopSoundClassification()
        cancellable?.cancel()
        decibelCancellable?.cancel()
        classificationSubject = nil
        audioEngine?.stop()
        audioEngine = nil
        isRecording = false
        currentDecibels = -160.0
    }
    
    private func setupAudioSession() throws {
        let audioSession = AVAudioSession.sharedInstance()
        try audioSession.setCategory(.playAndRecord, mode: .default)
        try audioSession.setActive(true)
    }
    
    private func setupAudioEngine() throws {
        audioEngine = AVAudioEngine()
        guard let audioEngine = audioEngine else {
            throw NSError(domain: "AudioProcessor", code: 0, userInfo: [NSLocalizedDescriptionKey: "Failed to create audio engine"])
        }
        
        let inputNode = audioEngine.inputNode
        let bus = 0
        let inputFormat = inputNode.outputFormat(forBus: bus)
        
        // Setup decibel extraction
        let decibelSubject = decibelExtractor.installTap(on: inputNode, bus: bus, bufferSize: 1024)
        decibelCancellable = decibelSubject
            .receive(on: DispatchQueue.main)
            .sink { [weak self] level in
                self?.currentDecibels = level
            }
        
        audioEngine.prepare()
    }
    
    private func handleClassificationResult(_ result: SNClassificationResult) {
        classifications = result.classifications
            .filter { $0.confidence > 0.05 }
            .map { classification in
            Classification(label: classification.identifier, confidence: classification.confidence)
        }
    }
}
