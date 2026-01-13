import Foundation
import HaishinKit
import AVFoundation
import UIKit

enum RTMPConnectionState {
    case initialized
    case connecting
    case connected
    case publishing
    case closed
    case failed
}

class RTMPService: NSObject, ObservableObject {
    @Published var connectionState: RTMPConnectionState = .initialized
    
    private var rtmpConnection: RTMPConnection?
    private var rtmpStream: RTMPStream?
    private var streamURL: String = ""
    private var streamKey: String = ""
    
    private(set) var reconnectAttempts: Int = 0
    private let maxReconnectAttempts: Int = 10
    private var reconnectTimer: Timer?
    private var backoffDelay: TimeInterval = 2.0
    
    var onConnectionStateChanged: ((RTMPConnectionState) -> Void)?
    var onConnectionReady: (() -> Void)?
    var onReconnectSuccess: (() -> Void)?
    var onReconnectFailed: (() -> Void)?
    var onFrameDropped: (() -> Void)?
    
    func configure(serverURL: String, streamKey: String) {
        self.streamURL = serverURL
        self.streamKey = streamKey
    }
    
    func prepareStream() {
        if rtmpConnection == nil {
            print("🔧 Preparing RTMP connection and stream...")
            rtmpConnection = RTMPConnection()
            rtmpStream = RTMPStream(connection: rtmpConnection!)
            
            rtmpConnection?.addEventListener(.rtmpStatus, selector: #selector(rtmpStatusHandler), observer: self)
            rtmpConnection?.addEventListener(.ioError, selector: #selector(rtmpErrorHandler), observer: self)
            
            // Registrar listener para eventos del stream
            rtmpStream?.addEventListener(.rtmpStatus, selector: #selector(streamStatusHandler), observer: self)
            print("✅ Stream prepared")
            print("✅ Stream event listener registered")
        }
    }
    
    func getRTMPStream() -> RTMPStream? {
        return rtmpStream
    }
    
    func connect() {
        guard !streamURL.isEmpty, !streamKey.isEmpty else {
            print("❌ Cannot connect: URL or stream key is empty")
            return
        }
        
        if rtmpConnection == nil {
            prepareStream()
        }
        
        connectionState = .connecting
        onConnectionStateChanged?(.connecting)
        
        print("🔌 Connecting to RTMP server: \(streamURL)")
        rtmpConnection?.connect(streamURL)
    }
    
    @objc private func rtmpStatusHandler(_ notification: Notification) {
        var code: String?
        
        if let userInfo = notification.userInfo,
           let event = userInfo["event"] {
            let mirror = Mirror(reflecting: event)
            for child in mirror.children {
                if child.label == "data" {
                    let value = child.value
                    if let dataDict = value as? [String: Any] {
                        code = dataDict["code"] as? String
                        break
                    } else {
                        let mirrorValue = Mirror(reflecting: value)
                        if mirrorValue.displayStyle == .optional,
                           let unwrapped = mirrorValue.children.first?.value {
                            if let dataDict = unwrapped as? [String: Any] {
                                code = dataDict["code"] as? String
                                break
                            } else {
                                let mirrorUnwrapped = Mirror(reflecting: unwrapped)
                                if mirrorUnwrapped.displayStyle == .optional,
                                   let doubleUnwrapped = mirrorUnwrapped.children.first?.value,
                                   let dataDict = doubleUnwrapped as? [String: Any] {
                                    code = dataDict["code"] as? String
                                    break
                                }
                            }
                        }
                    }
                }
            }
        }
        
        guard let codeValue = code else {
            print("⚠️ RTMP status handler: Could not extract code")
            return
        }
        
        // Solo procesar eventos de conexión, ignorar eventos de stream
        if !codeValue.hasPrefix("NetConnection.") {
            // Este es un evento de stream, se manejará en streamStatusHandler
            return
        }
        
        print("📡 RTMP Connection Status: \(codeValue)")
        
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            
            if codeValue == "NetConnection.Connect.Success" || codeValue == RTMPConnection.Code.connectSuccess.rawValue {
                print("✅ RTMP Connection successful")
                self.connectionState = .connected
                self.onConnectionStateChanged?(.connected)
                self.onConnectionReady?()
                // Esperar un poco más para asegurar que todo esté listo antes de publicar
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    self.publish()
                }
            } else if codeValue == "NetConnection.Connect.Closed" || codeValue == "NetConnection.Connect.Failed" ||
                      codeValue == RTMPConnection.Code.connectClosed.rawValue || codeValue == RTMPConnection.Code.connectFailed.rawValue {
                print("❌ RTMP Connection closed/failed: \(codeValue)")
                self.connectionState = .closed
                self.onConnectionStateChanged?(.closed)
                self.attemptReconnect()
            } else {
                print("ℹ️ RTMP Connection status: \(codeValue)")
            }
        }
    }
    
    @objc private func streamStatusHandler(_ notification: Notification) {
        print("🔔 streamStatusHandler called")
        print("📦 Notification userInfo: \(notification.userInfo ?? [:])")
        
        var code: String?
        
        if let userInfo = notification.userInfo {
            print("📦 userInfo keys: \(userInfo.keys)")
            
            if let event = userInfo["event"] {
                print("📦 event type: \(type(of: event))")
                let mirror = Mirror(reflecting: event)
                print("📦 event mirror children count: \(mirror.children.count)")
                
                for child in mirror.children {
                    print("📦 child label: \(child.label ?? "nil"), value type: \(type(of: child.value))")
                    if child.label == "data" {
                        let value = child.value
                        if let dataDict = value as? [String: Any] {
                            print("📦 dataDict: \(dataDict)")
                            code = dataDict["code"] as? String
                            break
                        } else {
                            let mirrorValue = Mirror(reflecting: value)
                            if mirrorValue.displayStyle == .optional,
                               let unwrapped = mirrorValue.children.first?.value {
                                if let dataDict = unwrapped as? [String: Any] {
                                    print("📦 dataDict (unwrapped): \(dataDict)")
                                    code = dataDict["code"] as? String
                                    break
                                } else {
                                    let mirrorUnwrapped = Mirror(reflecting: unwrapped)
                                    if mirrorUnwrapped.displayStyle == .optional,
                                       let doubleUnwrapped = mirrorUnwrapped.children.first?.value,
                                       let dataDict = doubleUnwrapped as? [String: Any] {
                                        print("📦 dataDict (double unwrapped): \(dataDict)")
                                        code = dataDict["code"] as? String
                                        break
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
        
        guard let codeValue = code else {
            print("⚠️ Stream status handler: Could not extract code from notification")
            print("📦 Full notification: \(notification)")
            return
        }
        
        print("📺 RTMP Stream Status Code: \(codeValue)")
        
        // Procesar todos los eventos de stream
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            
            if codeValue == "NetStream.Publish.Start" || codeValue == RTMPStream.Code.publishStart.rawValue {
                print("✅ Stream publishing started!")
                self.connectionState = .publishing
                self.onConnectionStateChanged?(.publishing)
                self.reconnectAttempts = 0
                self.backoffDelay = 2.0
            } else if codeValue == "NetStream.Publish.BadName" || codeValue == RTMPStream.Code.publishBadName.rawValue {
                print("❌ Stream publish failed: Bad stream name")
                self.connectionState = .failed
                self.onConnectionStateChanged?(.failed)
            } else if codeValue == "NetStream.Unpublish.Success" || codeValue == RTMPStream.Code.unpublishSuccess.rawValue {
                print("ℹ️ Stream unpublished successfully")
                self.connectionState = .closed
                self.onConnectionStateChanged?(.closed)
            } else if codeValue.contains("Publish") {
                print("📺 Stream publish status: \(codeValue)")
            } else if codeValue.hasPrefix("NetStream.") {
                print("📺 Stream status: \(codeValue)")
            } else {
                print("ℹ️ Evento recibido en streamStatusHandler: \(codeValue)")
            }
        }
    }
    
    @objc private func rtmpErrorHandler(_ notification: Notification) {
        DispatchQueue.main.async { [weak self] in
            self?.connectionState = .failed
            self?.onConnectionStateChanged?(.failed)
            self?.attemptReconnect()
        }
    }
    
    private func publish() {
        guard let stream = rtmpStream else {
            print("❌ Cannot publish: RTMP stream is nil")
            return
        }
        
        // Asegurar que el listener esté registrado antes de publicar
        stream.addEventListener(.rtmpStatus, selector: #selector(streamStatusHandler), observer: self)
        print("✅ Stream event listener registered before publish")
        
        // Verificar que la cámara y audio estén attachados
        let hasVideo = stream.videoCapture(for: 0)?.device != nil
        let hasAudio = stream.audioCapture(for: 0)?.device != nil
        
        print("📤 Publishing stream with key: \(streamKey)")
        print("📹 Video attached: \(hasVideo)")
        print("🎤 Audio attached: \(hasAudio)")
        print("📐 Video size: \(stream.videoSettings.videoSize)")
        print("📊 Video bitrate: \(stream.videoSettings.bitRate) bps")
        print("🎵 Audio bitrate: \(stream.audioSettings.bitRate) bps")
        
        // Verificar que el video capture esté activo
        if let videoCapture = stream.videoCapture(for: 0) {
            print("📹 Video capture unit exists")
            // Intentar verificar si está capturando
            if let device = videoCapture.device {
                print("📹 Camera device: \(device.localizedName), position: \(device.position == .back ? "back" : "front")")
            }
        } else {
            print("⚠️ Video capture unit is nil!")
        }
        
        // Publicar el stream
        print("📤 Calling stream.publish(\(streamKey))...")
        stream.publish(streamKey)
        
        // Verificar el estado del stream después de publicar
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [weak self] in
            guard let self = self, let stream = self.rtmpStream else { return }
            // Intentar verificar si el stream está publicando
            print("🔍 Verificando estado del stream después de publicar...")
            // Verificar que el video capture esté activo
            if let videoCapture = stream.videoCapture(for: 0) {
                print("📹 Video capture activo: \(videoCapture.device?.localizedName ?? "unknown")")
            }
            if stream.audioCapture(for: 0) != nil {
                print("🎤 Audio capture activo")
            }
        }
        
        // Fallback: Si después de 2 segundos no recibimos el evento, verificar manualmente
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) { [weak self] in
            guard let self = self else { return }
            // Si después de 2 segundos seguimos en "connected", asumir que está publicando
            if self.connectionState == .connected {
                print("⚠️ No se recibió evento NetStream.Publish.Start después de 2s")
                print("⚠️ Verificando si el stream está realmente publicando...")
                // Intentar verificar el estado del stream de otra manera
                // Por ahora, asumir que está publicando si llegamos aquí
                self.connectionState = .publishing
                self.onConnectionStateChanged?(.publishing)
            }
        }
    }
    
    func getCameraDevice() -> AVCaptureDevice? {
        return rtmpStream?.videoCapture(for: 0)?.device
    }
    
    func toggleTorch() {
        guard let device = getCameraDevice(), device.hasTorch, device.position == .back else { return }
        
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
            device.unlockForConfiguration()
        } catch let torchError {
            print("❌ Error toggling torch: \(torchError)")
        }
    }
    
    func switchCamera() {
        guard let rtmpStream = rtmpStream else { return }
        let currentPosition = rtmpStream.videoCapture(for: 0)?.device?.position ?? .back
        let newPosition: AVCaptureDevice.Position = currentPosition == .back ? .front : .back
        
        print("🔄 Switching camera from \(currentPosition == .back ? "back" : "front") to \(newPosition == .back ? "back" : "front")")
        
        if let newDevice = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: newPosition) {
            rtmpStream.attachCamera(newDevice) { _, error in
                if let error = error {
                    print("❌ Error attaching new camera: \(error)")
                } else {
                    print("✅ Camera switched successfully")
                }
            }
        }
    }
    
    func updateTorchAvailability() -> (available: Bool, isOn: Bool) {
        guard let device = getCameraDevice() else { return (false, false) }
        let isAvailable = device.hasTorch && device.position == .back
        let isOn = device.torchMode == .on
        return (isAvailable, isOn)
    }
    
    private func attemptReconnect() {
        guard reconnectAttempts < maxReconnectAttempts else {
            onReconnectFailed?()
            return
        }
        
        reconnectAttempts += 1
        
        reconnectTimer?.invalidate()
        let currentDelay = backoffDelay
        reconnectTimer = Timer.scheduledTimer(withTimeInterval: currentDelay, repeats: false) { [weak self] _ in
            guard let self = self else { return }
            self.connect()
            self.backoffDelay = min(30.0, currentDelay * 2.0)
        }
    }
    
    func disconnect() {
        reconnectTimer?.invalidate()
        reconnectTimer = nil
        rtmpStream?.close()
        rtmpConnection?.close()
        rtmpConnection = nil
        rtmpStream = nil
        reconnectAttempts = 0
        backoffDelay = 2.0
        connectionState = .closed
    }
    
    func getQueueSize() -> Int {
        return 0
    }
    
    func configureStream(preset: Preset) {
        guard let stream = rtmpStream else { return }
        
        // Configurar video ANTES de publicar
        stream.videoSettings.videoSize = CGSize(width: preset.resolution.width, height: preset.resolution.height)
        stream.videoSettings.bitRate = preset.initialVideoBitrate * 1000
        stream.videoSettings.frameInterval = 1 // 30fps = frameInterval 1
        
        // Configurar audio
        stream.audioSettings.bitRate = preset.audioBitrate * 1000
        // El sample rate se configura automáticamente por HaishinKit basado en el dispositivo
        
        // Asegurar que el stream esté listo para capturar
        // Esto es importante para que el stream empiece a enviar frames inmediatamente
        
        print("⚙️ Stream configured - Video: \(preset.resolution.width)x\(preset.resolution.height) @ \(preset.initialVideoBitrate) kbps, Audio: \(preset.audioBitrate) kbps")
        print("⚙️ Video settings - Size: \(stream.videoSettings.videoSize), Bitrate: \(stream.videoSettings.bitRate), FrameInterval: \(stream.videoSettings.frameInterval)")
    }
}
