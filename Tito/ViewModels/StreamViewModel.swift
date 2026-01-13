import Foundation
import Combine
import AVFoundation
import HaishinKit
import UIKit

class StreamViewModel: ObservableObject {
    @Published var streamState: StreamState = .idle
    @Published var currentPreset: Preset = .street // Cambiar a Street para mejor compatibilidad
    @Published var isMicrophoneEnabled: Bool = true
    @Published var telemetry: Telemetry = Telemetry()
    @Published var networkHealth: NetworkHealth = .good
    @Published var networkHealthMessage: String = ""
    @Published var showDiagnostics: Bool = false
    
    let rtmpService = RTMPService()
    let networkMonitor = NetworkMonitor.shared
    
    private var adaptTimer: Timer?
    private var telemetryTimer: Timer?
    private var cancellables = Set<AnyCancellable>()
    
    @Published var isTorchAvailable: Bool = false
    @Published var isTorchOn: Bool = false
    
    init() {
        setupAudioSession()
        setupBindings()
        rtmpService.prepareStream()
        updateTorchAvailability()
    }
    
    private func setupAudioSession() {
        let session = AVAudioSession.sharedInstance()
        do {
            try session.setCategory(.playAndRecord, mode: .default, options: [.defaultToSpeaker, .allowBluetoothHFP])
            try session.setActive(true)
            print("✅ AVAudioSession configured and activated")
        } catch {
            print("❌ Error setting up AVAudioSession: \(error)")
        }
    }
    
    private func setupBindings() {
        rtmpService.onConnectionStateChanged = { [weak self] state in
            DispatchQueue.main.async {
                self?.handleRTMPStateChange(state)
            }
        }
        
        rtmpService.onFrameDropped = { [weak self] in
            DispatchQueue.main.async {
                self?.telemetry.droppedVideoFrames += 1
            }
        }
        
        networkMonitor.$isConnected
            .sink { [weak self] connected in
                if !connected && self?.streamState.isActive == true {
                    self?.handleNetworkChange()
                }
            }
            .store(in: &cancellables)
    }
    
    func startPreview() {
        guard let rtmpStream = rtmpService.getRTMPStream() else {
            print("⚠️ Cannot start preview: RTMP stream is nil")
            return
        }
        
        print("📱 Starting preview...")
        
        // Attach camera (siempre empezar con la trasera)
        if let cameraDevice = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .back) {
            rtmpStream.attachCamera(cameraDevice) { _, error in
                if let error = error {
                    print("❌ Error attaching camera: \(error)")
                } else {
                    print("✅ Camera attached (back)")
                    // Esperar un momento para que el dispositivo se configure
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) { [weak self] in
                        self?.updateTorchAvailability()
                    }
                }
            }
        }
        
        // Attach audio
        if let audioDevice = AVCaptureDevice.default(for: .audio) {
            rtmpStream.attachAudio(audioDevice) { _, error in
                if let error = error {
                    print("❌ Error attaching audio: \(error)")
                } else {
                    print("✅ Audio attached")
                }
            }
        }
    }
    
    func stopPreview() {
        // HaishinKit maneja esto automáticamente
    }
    
    func toggleMicrophone() {
        isMicrophoneEnabled.toggle()
        // HaishinKit maneja el micrófono a través del stream
        // No hay una propiedad directa isEnabled en IOAudioCaptureUnit
        print("🎤 Microphone: \(isMicrophoneEnabled ? "ON" : "OFF")")
    }
    
    func toggleTorch() {
        guard let rtmpStream = rtmpService.getRTMPStream(),
              let cameraDevice = rtmpStream.videoCapture(for: 0)?.device,
              cameraDevice.hasTorch else {
            return
        }
        
        do {
            try cameraDevice.lockForConfiguration()
            let wasOn = cameraDevice.torchMode == .on
            if wasOn {
                cameraDevice.torchMode = .off
            } else {
                try cameraDevice.setTorchModeOn(level: 1.0)
            }
            DispatchQueue.main.async { [weak self] in
                self?.isTorchOn = cameraDevice.torchMode == .on
            }
            cameraDevice.unlockForConfiguration()
        } catch {
            print("❌ Error toggling torch: \(error)")
        }
    }
    
    func switchCamera() {
        guard let rtmpStream = rtmpService.getRTMPStream() else { return }
        
        let currentPosition = rtmpStream.videoCapture(for: 0)?.device?.position ?? .back
        let newPosition: AVCaptureDevice.Position = currentPosition == .back ? .front : .back
        
        if let newDevice = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: newPosition) {
            rtmpStream.attachCamera(newDevice) { _, error in
                if let error = error {
                    print("❌ Error switching camera: \(error)")
                } else {
                    print("✅ Camera switched to \(newPosition == .back ? "back" : "front")")
                    // Esperar un momento para que el dispositivo se configure antes de actualizar el flash
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) { [weak self] in
                        self?.updateTorchAvailability()
                    }
                }
            }
        }
    }
    
    private func updateTorchAvailability() {
        DispatchQueue.main.async { [weak self] in
            guard let self = self,
                  let rtmpStream = self.rtmpService.getRTMPStream(),
                  let cameraDevice = rtmpStream.videoCapture(for: 0)?.device else {
                self?.isTorchAvailable = false
                self?.isTorchOn = false
                print("💡 Flash no disponible: dispositivo no encontrado")
                return
            }
            
            let position = cameraDevice.position
            let hasTorch = cameraDevice.hasTorch
            let isBackCamera = (position == .back)
            
            self.isTorchAvailable = hasTorch && isBackCamera
            self.isTorchOn = cameraDevice.torchMode == .on
            
            print("💡 Flash - Posición: \(position == .back ? "back" : "front"), hasTorch: \(hasTorch), disponible: \(self.isTorchAvailable), encendido: \(self.isTorchOn)")
        }
    }
    
    func startStream() {
        guard let config = KeychainService.shared.loadStreamConfig(), config.isValid else {
            streamState = .failed(error: "Configuración de Restream no válida")
            return
        }
        
        print("🚀 Starting stream to Restream...")
        streamState = .connecting
        telemetry.reset()
        telemetry.startTime = Date()
        
        guard let rtmpStream = rtmpService.getRTMPStream() else {
            streamState = .failed(error: "RTMP stream no está preparado")
            return
        }
        
        // IMPORTANTE: Configurar el stream PRIMERO, antes de attachar cámara/audio
        // Esto asegura que el stream tenga la configuración correcta cuando se attachan los dispositivos
        rtmpService.configureStream(preset: currentPreset)
        print("⚙️ Stream configured with preset: \(currentPreset.displayName)")
        
        // Verificar que la cámara y audio estén attachados
        // Si ya están attachados desde startPreview(), están bien
        // Si no, los attachamos ahora
        let videoCapture = rtmpStream.videoCapture(for: 0)
        let audioCapture = rtmpStream.audioCapture(for: 0)
        
        print("📹 Video capture status: \(videoCapture != nil ? "exists" : "nil")")
        print("🎤 Audio capture status: \(audioCapture != nil ? "exists" : "nil")")
        
        // Si la cámara no está attachada, attacharla ahora (después de configurar el stream)
        if videoCapture?.device == nil {
            print("⚠️ Camera device not attached, attaching now...")
            if let cameraDevice = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .back) {
                rtmpStream.attachCamera(cameraDevice) { _, error in
                    if let error = error {
                        print("❌ Error attaching camera: \(error)")
                    } else {
                        print("✅ Camera attached for streaming")
                    }
                }
            }
        } else {
            print("✅ Camera already attached: \(videoCapture?.device?.localizedName ?? "unknown")")
        }
        
        // Si el audio no está attachado, attacharlo ahora
        if audioCapture?.device == nil {
            print("⚠️ Audio device not attached, attaching now...")
            if let audioDevice = AVCaptureDevice.default(for: .audio) {
                rtmpStream.attachAudio(audioDevice) { _, error in
                    if let error = error {
                        print("❌ Error attaching audio: \(error)")
                    } else {
                        print("✅ Audio attached for streaming")
                    }
                }
            }
        } else {
            print("✅ Audio already attached")
        }
        
        // IMPORTANTE: Esperar a que la cámara y audio estén completamente listos antes de conectar
        // HaishinKit necesita tiempo para inicializar la captura antes de publicar
        print("⏳ Esperando a que la cámara y audio estén listos...")
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self] in
            guard let self = self else { return }
            // Verificar una vez más que todo esté listo
            let finalVideoCapture = rtmpStream.videoCapture(for: 0)
            let finalAudioCapture = rtmpStream.audioCapture(for: 0)
            print("🔍 Verificación final - Video: \(finalVideoCapture != nil ? "OK" : "MISSING"), Audio: \(finalAudioCapture != nil ? "OK" : "MISSING")")
            
            // Configurar y conectar
            self.rtmpService.configure(serverURL: config.serverURL, streamKey: config.streamKey)
            self.rtmpService.connect()
        }
        
        startTelemetryUpdates()
        startAdaptiveBitrate()
    }
    
    func stopStream() {
        let duration = telemetry.duration
        streamState = .ended(duration: duration)
        
        rtmpService.disconnect()
        adaptTimer?.invalidate()
        telemetryTimer?.invalidate()
    }
    
    private func handleRTMPStateChange(_ state: RTMPConnectionState) {
        print("🔄 StreamViewModel: RTMP state changed to \(state)")
        switch state {
        case .connecting:
            if case .idle = streamState {
                streamState = .connecting
            } else if case .streaming = streamState {
                let attempt = rtmpService.reconnectAttempts
                streamState = .reconnecting(attempt: attempt)
            }
        case .connected:
            print("✅ Connected to RTMP server, waiting for publish...")
            break
        case .publishing:
            streamState = .streaming
            print("✅ Stream is now LIVE!")
        case .closed, .failed:
            if streamState.isActive {
                let attempt = rtmpService.reconnectAttempts
                streamState = .reconnecting(attempt: attempt)
            } else {
                streamState = .failed(error: "Conexión cerrada")
            }
        default:
            break
        }
    }
    
    private func handleNetworkChange() {
        if case .streaming = streamState {
            streamState = .reconnecting(attempt: 1)
        }
    }
    
    private func startTelemetryUpdates() {
        telemetryTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            guard let self = self else { return }
            
            self.telemetry.queueSize = self.rtmpService.getQueueSize()
            self.networkHealth = NetworkHealth.from(telemetry: self.telemetry, preset: self.currentPreset)
            self.networkHealthMessage = self.networkHealth.message
        }
    }
    
    private func startAdaptiveBitrate() {
        adaptTimer = Timer.scheduledTimer(withTimeInterval: 5.0, repeats: true) { [weak self] _ in
            guard let self = self, case .streaming = self.streamState else { return }
            
            if let rtmpStream = self.rtmpService.getRTMPStream() {
                self.telemetry.currentBitrate = Int(rtmpStream.videoSettings.bitRate / 1000)
            }
        }
    }
}
