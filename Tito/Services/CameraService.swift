import Foundation
import AVFoundation
import Combine
import UIKit

class CameraService: NSObject, ObservableObject {
    @Published var previewLayer: AVCaptureVideoPreviewLayer?
    @Published var isTorchAvailable: Bool = false
    @Published var isTorchOn: Bool = false
    @Published var error: String?
    
    private let captureSession = AVCaptureSession()
    private var videoOutput: AVCaptureVideoDataOutput?
    private var currentCamera: AVCaptureDevice?
    private var currentPosition: AVCaptureDevice.Position = .back
    
    var videoOutputHandler: ((CMSampleBuffer) -> Void)?
    
    // Exponer el dispositivo de cámara para HaishinKit
    var cameraDevice: AVCaptureDevice? {
        return currentCamera
    }
    
    override init() {
        super.init()
        setupCaptureSession()
    }
    
    private func setupCaptureSession() {
        captureSession.sessionPreset = .high
        
        guard let videoDevice = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .back) else {
            DispatchQueue.main.async { [weak self] in
                self?.error = "No se pudo acceder a la cámara"
            }
            return
        }
        
        guard let videoInput = try? AVCaptureDeviceInput(device: videoDevice) else {
            DispatchQueue.main.async { [weak self] in
                self?.error = "No se pudo crear el input de la cámara"
            }
            return
        }
        
        if captureSession.canAddInput(videoInput) {
            captureSession.addInput(videoInput)
            currentCamera = videoDevice
            currentPosition = .back
        }
        
        videoOutput = AVCaptureVideoDataOutput()
        videoOutput?.setSampleBufferDelegate(self, queue: DispatchQueue(label: "video.capture.queue"))
        videoOutput?.videoSettings = [
            kCVPixelBufferPixelFormatTypeKey as String: kCVPixelFormatType_32BGRA
        ]
        
        if let videoOutput = videoOutput, captureSession.canAddOutput(videoOutput) {
            captureSession.addOutput(videoOutput)
        }
        
        // Crear preview layer inmediatamente en el hilo principal
        let previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        previewLayer.videoGravity = .resizeAspectFill
        DispatchQueue.main.async { [weak self] in
            self?.previewLayer = previewLayer
            print("✅ Preview layer created in init")
        }
        
        updateTorchAvailability()
    }
    
    func startSession() {
        guard !captureSession.isRunning else { 
            print("⚠️ Session already running")
            // Asegurar que el preview layer esté asignado incluso si la sesión ya está corriendo
            if previewLayer == nil {
                DispatchQueue.main.async { [weak self] in
                    guard let self = self else { return }
                    let previewLayer = AVCaptureVideoPreviewLayer(session: self.captureSession)
                    previewLayer.videoGravity = .resizeAspectFill
                    self.previewLayer = previewLayer
                    print("✅ Preview layer created (session already running)")
                }
            }
            return 
        }
        
        // Crear preview layer ANTES de iniciar la sesión si no existe
        if previewLayer == nil {
            print("📷 Creating preview layer before starting session...")
            let newPreviewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
            newPreviewLayer.videoGravity = .resizeAspectFill
            DispatchQueue.main.async { [weak self] in
                self?.previewLayer = newPreviewLayer
                print("✅ Preview layer created and assigned")
            }
        }
        
        // Iniciar la sesión en un hilo de fondo
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            guard let self = self else { return }
            print("🚀 Starting capture session...")
            self.captureSession.startRunning()
            
            // Esperar un momento para que la sesión inicie completamente
            Thread.sleep(forTimeInterval: 0.2)
            
            // Verificar que la sesión esté corriendo
            DispatchQueue.main.async {
                if self.captureSession.isRunning {
                    print("✅ Capture session started successfully")
                    // Asegurar que el preview layer esté asignado
                    if self.previewLayer == nil {
                        let newPreviewLayer = AVCaptureVideoPreviewLayer(session: self.captureSession)
                        newPreviewLayer.videoGravity = .resizeAspectFill
                        self.previewLayer = newPreviewLayer
                        print("✅ Preview layer created after session started")
                    } else {
                        print("📹 Preview layer already exists, forcing update")
                        // Forzar actualización publicando el cambio
                        let existingLayer = self.previewLayer
                        self.previewLayer = nil
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
                            self.previewLayer = existingLayer
                            print("✅ Preview layer republished")
                        }
                    }
                } else {
                    print("❌ Capture session failed to start")
                }
            }
        }
    }
    
    func stopSession() {
        guard captureSession.isRunning else { return }
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            self?.captureSession.stopRunning()
        }
    }
    
    func switchCamera() {
        print("📷 switchCamera called")
        guard let currentInput = captureSession.inputs.first as? AVCaptureDeviceInput else {
            print("❌ No current input found")
            return
        }
        
        let newPosition: AVCaptureDevice.Position = currentPosition == .back ? .front : .back
        print("🔄 Switching camera from \(currentPosition == .back ? "back" : "front") to \(newPosition == .back ? "back" : "front")")
        
        guard let newDevice = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: newPosition) else {
            print("❌ Failed to get new device")
            return
        }
        
        guard let newInput = try? AVCaptureDeviceInput(device: newDevice) else {
            print("❌ Failed to create new device input")
            return
        }
        
        captureSession.beginConfiguration()
        captureSession.removeInput(currentInput)
        
        if captureSession.canAddInput(newInput) {
            captureSession.addInput(newInput)
            currentCamera = newDevice
            currentPosition = newPosition
            print("✅ Camera switched successfully")
        } else {
            captureSession.addInput(currentInput)
            print("❌ Failed to add new input, reverting")
        }
        
        captureSession.commitConfiguration()
        
        // Actualizar disponibilidad del flash ANTES de actualizar el preview
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            self.updateTorchAvailability()
            
            // Actualizar el preview layer
            if let connection = self.previewLayer?.connection, connection.isVideoMirroringSupported {
                connection.automaticallyAdjustsVideoMirroring = false
                connection.isVideoMirrored = newPosition == .front
            }
            // Forzar actualización del preview
            if let previewLayer = self.previewLayer {
                self.previewLayer = previewLayer
            }
        }
    }
    
    func toggleTorch() {
        guard let device = currentCamera, device.hasTorch, currentPosition == .back else { return }
        
        do {
            try device.lockForConfiguration()
            let wasOn = device.torchMode == .on
            if wasOn {
                device.torchMode = .off
                print("💡 Torch turned OFF")
            } else {
                try device.setTorchModeOn(level: 1.0)
                print("💡 Torch turned ON")
            }
            // Actualizar el estado en el hilo principal DESPUÉS de cambiar el modo
            let newTorchState = device.torchMode == .on
            DispatchQueue.main.async { [weak self] in
                self?.isTorchOn = newTorchState
                print("💡 isTorchOn updated to: \(newTorchState)")
            }
            device.unlockForConfiguration()
        } catch let torchError {
            print("❌ Error toggling torch: \(torchError)")
            DispatchQueue.main.async { [weak self] in
                self?.error = "No se pudo controlar el flash: \(torchError.localizedDescription)"
            }
        }
    }
    
    func configureForPreset(_ preset: Preset) {
        guard let device = currentCamera else { return }
        
        do {
            try device.lockForConfiguration()
            
            if let format = device.formats.first(where: { format in
                let dimensions = CMVideoFormatDescriptionGetDimensions(format.formatDescription)
                return Int(dimensions.width) == Int(preset.resolution.width) &&
                       Int(dimensions.height) == Int(preset.resolution.height) &&
                       format.videoSupportedFrameRateRanges.contains(where: { range in
                           range.maxFrameRate >= Double(preset.frameRate)
                       })
            }) {
                device.activeFormat = format
                
                if format.videoSupportedFrameRateRanges.contains(where: { range in
                    range.maxFrameRate >= Double(preset.frameRate)
                }) {
                    device.activeVideoMinFrameDuration = CMTime(value: 1, timescale: Int32(preset.frameRate))
                    device.activeVideoMaxFrameDuration = CMTime(value: 1, timescale: Int32(preset.frameRate))
                }
            }
            
            device.unlockForConfiguration()
        } catch let configError {
            DispatchQueue.main.async { [weak self] in
                self?.error = "No se pudo configurar la cámara para el preset: \(configError.localizedDescription)"
            }
        }
    }
    
    private func updateTorchAvailability() {
        let wasAvailable = isTorchAvailable
        let newAvailability = currentCamera?.hasTorch == true && currentPosition == .back
        isTorchAvailable = newAvailability
        if !isTorchAvailable {
            isTorchOn = false
        }
        // Solo imprimir si realmente cambió
        if wasAvailable != isTorchAvailable {
            print("💡 Torch availability changed: \(isTorchAvailable)")
        }
    }
}

extension CameraService: AVCaptureVideoDataOutputSampleBufferDelegate {
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        videoOutputHandler?(sampleBuffer)
    }
}
