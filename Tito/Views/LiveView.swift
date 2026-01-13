import SwiftUI
import HaishinKit

struct LiveView: View {
    @ObservedObject var viewModel: StreamViewModel
    @Environment(\.dismiss) var dismiss
    @State private var showEndView = false
    @State private var versionTapCount = 0
    
    var body: some View {
        ZStack {
            CameraPreviewView(viewModel: viewModel)
                .ignoresSafeArea()
            
            VStack {
                // Top Status Bar
                HStack {
                    HStack(spacing: 8) {
                        Circle()
                            .fill(Color.red)
                            .frame(width: 10, height: 10)
                        Text("EN VIVO")
                            .font(.caption)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                    }
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(Color.black.opacity(0.7))
                    .cornerRadius(8)
                    
                    Spacer()
                    
                    // Active Platforms Indicator
                    HStack(spacing: 6) {
                        Image(systemName: KeychainService.shared.loadDestination().icon)
                            .font(.caption)
                        Text(KeychainService.shared.loadDestination().displayName)
                            .font(.caption)
                            .fontWeight(.medium)
                    }
                    .foregroundColor(.white)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 6)
                    .background(Color.black.opacity(0.7))
                    .cornerRadius(8)
                    
                    Spacer()
                    
                    VStack(spacing: 4) {
                        Text(formatDuration(viewModel.telemetry.duration))
                            .font(.system(.headline, design: .monospaced))
                            .foregroundColor(.white)
                    }
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(Color.black.opacity(0.7))
                    .cornerRadius(8)
                }
                .padding()
                
                Spacer()
                
                // Telemetry Panel
                VStack(alignment: .leading, spacing: 12) {
                    HStack {
                        Circle()
                            .fill(viewModel.networkHealth.color)
                            .frame(width: 10, height: 10)
                        Text(viewModel.networkHealthMessage)
                            .font(.caption)
                            .foregroundColor(.white)
                    }
                    
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Preset: \(viewModel.currentPreset.displayName)")
                            .font(.caption)
                            .foregroundColor(.white.opacity(0.8))
                        Text("Bitrate: \(viewModel.telemetry.currentBitrate) kbps")
                            .font(.caption)
                            .foregroundColor(.white.opacity(0.8))
                        Text("Frames perdidos: \(viewModel.telemetry.droppedVideoFrames)")
                            .font(.caption)
                            .foregroundColor(.white.opacity(0.8))
                        Text("Cola: \(viewModel.telemetry.queueSize)")
                            .font(.caption)
                            .foregroundColor(.white.opacity(0.8))
                    }
                }
                .padding()
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(Color.black.opacity(0.7))
                .cornerRadius(12)
                .padding(.horizontal)
                
                // Controls
                HStack(spacing: 30) {
                    Button(action: {
                        viewModel.switchCamera()
                    }) {
                        Image(systemName: "camera.rotate")
                            .font(.title2)
                            .foregroundColor(.white)
                            .frame(width: 50, height: 50)
                            .background(Color.black.opacity(0.6))
                            .clipShape(Circle())
                    }
                    
                    Button(action: {
                        viewModel.stopStream()
                        showEndView = true
                    }) {
                        Text("Finalizar")
                            .fontWeight(.semibold)
                            .foregroundColor(.white)
                            .frame(width: 120, height: 50)
                            .background(Color.red)
                            .cornerRadius(25)
                    }
                }
                .padding(.bottom, 40)
            }
        }
        .onAppear {
            UIApplication.shared.isIdleTimerDisabled = true
        }
        .onDisappear {
            UIApplication.shared.isIdleTimerDisabled = false
        }
        .sheet(isPresented: $showEndView) {
            EndView(duration: viewModel.telemetry.duration) {
                dismiss()
            }
        }
        .sheet(isPresented: $viewModel.showDiagnostics) {
            DiagnosticsView(viewModel: viewModel)
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
