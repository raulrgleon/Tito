import SwiftUI

struct DiagnosticsView: View {
    @ObservedObject var viewModel: StreamViewModel
    
    var body: some View {
        NavigationView {
            List {
                Section("Estado") {
                    HStack {
                        Text("Estado de Transmisión")
                        Spacer()
                        Text(viewModel.streamState.displayName)
                            .foregroundColor(.secondary)
                    }
                    
                    HStack {
                        Text("Preset Actual")
                        Spacer()
                        Text(viewModel.currentPreset.displayName)
                            .foregroundColor(.secondary)
                    }
                }
                
                Section("Telemetría") {
                    HStack {
                        Text("Frames Perdidos")
                        Spacer()
                        Text("\(viewModel.telemetry.droppedVideoFrames)")
                            .foregroundColor(.secondary)
                    }
                    
                    HStack {
                        Text("Bitrate Actual")
                        Spacer()
                        Text("\(viewModel.telemetry.currentBitrate) kbps")
                            .foregroundColor(.secondary)
                    }
                    
                    HStack {
                        Text("Bitrate Promedio")
                        Spacer()
                        Text("\(viewModel.telemetry.averageBitrate) kbps")
                            .foregroundColor(.secondary)
                    }
                    
                    HStack {
                        Text("Tamaño de Cola")
                        Spacer()
                        Text("\(viewModel.telemetry.queueSize)")
                            .foregroundColor(.secondary)
                    }
                    
                    HStack {
                        Text("RTT Estimado")
                        Spacer()
                        Text(String(format: "%.0f ms", viewModel.telemetry.estimatedRTT * 1000))
                            .foregroundColor(.secondary)
                    }
                    
                    HStack {
                        Text("Duración")
                        Spacer()
                        Text(formatDuration(viewModel.telemetry.duration))
                            .foregroundColor(.secondary)
                    }
                }
                
                Section("Red") {
                    HStack {
                        Text("Estado de Red")
                        Spacer()
                        Text(viewModel.networkHealth.rawValue)
                            .foregroundColor(viewModel.networkHealth.color)
                    }
                    
                    HStack {
                        Text("Mensaje")
                        Spacer()
                        Text(viewModel.networkHealthMessage)
                            .foregroundColor(.secondary)
                    }
                }
            }
            .navigationTitle("Diagnósticos")
            .navigationBarTitleDisplayMode(.inline)
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
