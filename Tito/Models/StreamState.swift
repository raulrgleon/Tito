import Foundation

enum StreamState: Equatable {
    case idle
    case connecting
    case streaming
    case reconnecting(attempt: Int)
    case failed(error: String)
    case ended(duration: TimeInterval)
    
    var isActive: Bool {
        switch self {
        case .streaming, .reconnecting:
            return true
        default:
            return false
        }
    }
    
    var displayName: String {
        switch self {
        case .idle:
            return "Listo"
        case .connecting:
            return "Conectando..."
        case .streaming:
            return "En Vivo"
        case .reconnecting(let attempt):
            return "Reconectando... (Intento \(attempt))"
        case .failed(let error):
            return "Error: \(error)"
        case .ended(let duration):
            return "Finalizado (\(formatDuration(duration)))"
        }
    }
    
    private func formatDuration(_ duration: TimeInterval) -> String {
        let hours = Int(duration) / 3600
        let minutes = Int(duration) / 60 % 60
        let seconds = Int(duration) % 60
        if hours > 0 {
            return String(format: "%d:%02d:%02d", hours, minutes, seconds)
        }
        return String(format: "%d:%02d", minutes, seconds)
    }
}
