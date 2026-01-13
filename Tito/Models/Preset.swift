import Foundation
import AVFoundation

enum Preset: String, CaseIterable, Identifiable {
    case street = "Street"
    case wifi = "Wi-Fi"
    case highQuality = "High Quality"
    
    var id: String { rawValue }
    
    var displayName: String { rawValue }
    
    var resolution: CGSize {
        switch self {
        case .street:
            return CGSize(width: 1280, height: 720)
        case .wifi, .highQuality:
            return CGSize(width: 1920, height: 1080)
        }
    }
    
    var frameRate: Int32 {
        switch self {
        case .street, .wifi:
            return 30
        case .highQuality:
            return 60
        }
    }
    
    var videoBitrateRange: ClosedRange<Int> {
        switch self {
        case .street:
            return 2000...3000
        case .wifi:
            return 4500...6000
        case .highQuality:
            return 6500...9000
        }
    }
    
    var initialVideoBitrate: Int {
        switch self {
        case .street:
            return 2500
        case .wifi:
            return 5000
        case .highQuality:
            return 7500
        }
    }
    
    var audioBitrate: Int {
        return 128
    }
    
    var audioSampleRate: Double {
        return 48000
    }
    
    var keyframeInterval: TimeInterval {
        return 2.0
    }
    
    var description: String {
        switch self {
        case .street:
            return "720p @ 30fps - Optimizado para estabilidad"
        case .wifi:
            return "1080p @ 30fps - Calidad alta en Wi-Fi"
        case .highQuality:
            return "1080p @ 60fps - Máxima calidad"
        }
    }
}
