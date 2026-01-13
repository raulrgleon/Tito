import Foundation
import SwiftUI

struct Telemetry {
    var droppedVideoFrames: Int = 0
    var currentBitrate: Int = 0 // kbps
    var estimatedRTT: TimeInterval = 0 // ms
    var queueSize: Int = 0
    var totalBytesSent: Int64 = 0
    var startTime: Date?
    
    var duration: TimeInterval {
        guard let start = startTime else { return 0 }
        return Date().timeIntervalSince(start)
    }
    
    var averageBitrate: Int {
        guard duration > 0 else { return 0 }
        return Int(Double(totalBytesSent * 8) / duration / 1000) // kbps
    }
    
    mutating func reset() {
        droppedVideoFrames = 0
        currentBitrate = 0
        estimatedRTT = 0
        queueSize = 0
        totalBytesSent = 0
        startTime = nil
    }
}

enum NetworkHealth: String {
    case excellent = "Excelente"
    case good = "Buena"
    case fair = "Regular"
    case poor = "Mala"
    
    var color: Color {
        switch self {
        case .excellent, .good:
            return .green
        case .fair:
            return .yellow
        case .poor:
            return .red
        }
    }
    
    var message: String {
        switch self {
        case .excellent:
            return "Conexión excelente"
        case .good:
            return "Conexión buena"
        case .fair:
            return "Conexión inestable, ajustando calidad"
        case .poor:
            return "Conexión débil, reduciendo calidad"
        }
    }
    
    static func from(telemetry: Telemetry, preset: Preset) -> NetworkHealth {
        let bitrateRatio = Double(telemetry.currentBitrate) / Double(preset.initialVideoBitrate)
        let droppedFramesRatio = Double(telemetry.droppedVideoFrames) / max(1.0, Double(telemetry.duration))
        
        if telemetry.estimatedRTT > 500 || droppedFramesRatio > 0.1 || bitrateRatio < 0.5 {
            return .poor
        } else if telemetry.estimatedRTT > 300 || droppedFramesRatio > 0.05 || bitrateRatio < 0.7 {
            return .fair
        } else if telemetry.estimatedRTT < 100 && droppedFramesRatio < 0.01 && bitrateRatio > 0.9 {
            return .excellent
        } else {
            return .good
        }
    }
}
