//import SwiftUI
//import AVFoundation
//import PhotosUI
//import Observation
//
//@Observable
//class CameraManager: NSObject, AVCapturePhotoCaptureDelegate {
//    private var captureSession: AVCaptureSession?
//    private var photoOutput: AVCapturePhotoOutput?
//    private var completionHandler: ((CGImage?) -> Void)?
//    
//    override init() {
//        super.init()
//        setupCaptureSession()
//    }
//    
//    private func setupCaptureSession() {
//        captureSession = AVCaptureSession()
//        guard let captureSession = captureSession else { return }
//        
//        // Try to get the ultra-wide camera first
//        var camera: AVCaptureDevice?
//        if let ultraWideCamera = AVCaptureDevice.default(.builtInUltraWideCamera, for: .video, position: .back) {
//            camera = ultraWideCamera
//        } else if let wideCamera = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .back) {
//            // Fall back to wide-angle camera if ultra-wide is not available
//            camera = wideCamera
//        }
//        
//        guard let camera = camera else {
//            print("Failed to get camera")
//            return
//        }
//        
//        do {
//            let input = try AVCaptureDeviceInput(device: camera)
//            if captureSession.canAddInput(input) {
//                captureSession.addInput(input)
//            }
//            
//            photoOutput = AVCapturePhotoOutput()
//            if captureSession.canAddOutput(photoOutput!) {
//                captureSession.addOutput(photoOutput!)
//            }
//            
//            captureSession.startRunning()
//        } catch {
//            print("Failed to set up camera: \(error)")
//        }
//    }
//    
//    func capturePhoto(completion: @escaping (CGImage?) -> Void) {
//        guard let photoOutput = photoOutput else {
//            completion(nil)
//            return
//        }
//        
//        self.completionHandler = completion
//        
//        let settings = AVCapturePhotoSettings()
//        photoOutput.capturePhoto(with: settings, delegate: self)
//    }
//    
//    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
//        guard let imageData = photo.cgImageRepresentation() else {
//            completionHandler?(nil)
//            return
//        }
//        
//        
//        completionHandler?(imageData)
//    }
//    
//    func makePreviewLayer() -> AVCaptureVideoPreviewLayer? {
//        guard let captureSession = captureSession else { return nil }
//        let previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
//        previewLayer.videoGravity = .resizeAspectFill
//        return previewLayer
//    }
//}
//
//struct CameraPreview: UIViewRepresentable {
//    let cameraManager: CameraManager
//    
//    func makeUIView(context: Context) -> UIView {
//        let view = UIView(frame: UIScreen.main.bounds)
//        
//        guard let previewLayer = cameraManager.makePreviewLayer() else {
//            return view
//        }
//        
//        previewLayer.frame = view.bounds
//        view.layer.addSublayer(previewLayer)
//        
//        return view
//    }
//    
//    func updateUIView(_ uiView: UIView, context: Context) {
//        if let previewLayer = uiView.layer.sublayers?.first as? AVCaptureVideoPreviewLayer {
//            updatePreviewLayerOrientation(previewLayer)
//        }
//    }
//    
//    private func updatePreviewLayerOrientation(_ previewLayer: AVCaptureVideoPreviewLayer) {
//        let orientation = UIDevice.current.orientation
//        let videoOrientation = AVCaptureVideoOrientation(deviceOrientation: orientation) ?? .portrait
//        if previewLayer.connection?.isVideoOrientationSupported == true {
//            previewLayer.connection?.videoOrientation = videoOrientation
//        }
//    }
//}
//
//struct FlashEffect: ViewModifier {
//    let isVisible: Bool
//    
//    func body(content: Content) -> some View {
//        content
//            .overlay(
//                RoundedRectangle(cornerRadius: 0)
//                    .stroke(Color.white, lineWidth: 6)
//                    .opacity(isVisible ? 1 : 0)
//            )
//    }
//}
//
//struct IntervalPhotoCapture: View {
//    @State private var cameraManager = CameraManager()
//    @State private var isCaptureActive = false
//    @State private var timer: Timer?
//    @State private var cameraAuthorized = false
//    @State private var isFlashing = false
//    
//    var body: some View {
//        ZStack {
//            CameraPreview(cameraManager: cameraManager)
//                .edgesIgnoringSafeArea(.all)
//                .modifier(FlashEffect(isVisible: isFlashing))
//            
//            VStack {
//                Spacer()
//                Button(action: toggleCapture) {
//                    Text(isCaptureActive ? "Stop Capture" : "Start Capture")
//                        .padding()
//                        .background(isCaptureActive ? Color.red : Color.blue)
//                        .foregroundColor(.white)
//                        .cornerRadius(10)
//                }
//                .disabled(!cameraAuthorized)
//                .padding(.bottom, 30)
//            }
//        }
//        .onAppear(perform: requestCameraPermission)
//    }
//    
//    private func requestCameraPermission() {
//        AVCaptureDevice.requestAccess(for: .video) { granted in
//            DispatchQueue.main.async {
//                self.cameraAuthorized = granted
//            }
//        }
//    }
//    
//    private func toggleCapture() {
//        isCaptureActive.toggle()
//        if isCaptureActive {
//            startIntervalCapture()
//        } else {
//            stopIntervalCapture()
//        }
//    }
//    
//    private func startIntervalCapture() {
//        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in
//            captureAndSavePhoto()
//        }
//    }
//    
//    private func stopIntervalCapture() {
//        timer?.invalidate()
//        timer = nil
//    }
//    
//    private func captureAndSavePhoto() {
//        cameraManager.capturePhoto { image in
//            guard let image = image else { return }
//            savePhotoToLibrary(photoData: image)
//            showFlashEffect()
//        }
//    }
//    
//    func savePhotoToLibrary(phoŹoData: CGImage) {
//        PHPhotoLibrary.requestAuthorization { status in
////            if status == .authorized {
//                PHPhotoLibrary.shared().performChanges({
//                    let creationRequest = PHAssetCreationRequest.forAsset()
//                    creationRequest.addResource(with: .photo, data: UIImage, options: <#T##PHAssetResourceCreationOptions?#>)
////                    creationRequest.addResource(with: .photo, data: photoData, options: nil)
//                }) { success, error in
//                    if success {
//                        print("Photo saved successfully")
//                    } else if let error = error {
//                        print("Error saving photo: \(error.localizedDescription)")
//                    }
//                }
////            } else {
////                print("Photo library access denied")
////            }
//        }
//    }
//    
//    
//    
//    private func showFlashEffect() {
//        isFlashing = true
//        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
//            isFlashing = false
//        }
//    }
//}
//
//struct IntervalPhotoCapture_Previews: PreviewProvider {
//    static var previews: some View {
//        IntervalPhotoCapture()
//    }
//}
//
//
//// Helper extension to convert UIDeviceOrientation to AVCaptureVideoOrientation
//extension AVCaptureVideoOrientation {
//    init?(deviceOrientation: UIDeviceOrientation) {
//        switch deviceOrientation {
//        case .portrait: self = .portrait
//        case .portraitUpsideDown: self = .portraitUpsideDown
//        case .landscapeLeft: self = .landscapeRight
//        case .landscapeRight: self = .landscapeLeft
//        default: return nil
//        }
//    }
//}
