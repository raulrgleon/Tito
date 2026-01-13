import SwiftUI
import AVFoundation
import HaishinKit

struct PreviewView: View {
    @StateObject private var viewModel = StreamViewModel()
    @State private var versionTapCount = 0
    @State private var showSettings = false
    
    private var statusColor: Color {
        switch viewModel.streamState {
        case .idle:
            return .gray
        case .connecting, .reconnecting:
            return .yellow
        case .streaming:
            return .green
        case .failed:
            return .red
        case .ended:
            return .gray
        }
    }
    
    private var statusMessage: String {
        switch viewModel.streamState {
        case .idle:
            return "Listo"
        case .connecting:
            return "Conectando a Restream..."
        case .streaming:
            return "EN VIVO"
        case .reconnecting(let attempt):
            return "Reconectando... (\(attempt))"
        case .failed(let error):
            return "Error: \(error)"
        case .ended:
            return "Finalizado"
        }
    }
    
    private var networkSignalIcon: String {
        if viewModel.networkMonitor.isWiFi {
            return "wifi"
        } else if viewModel.networkMonitor.isCellular {
            return "antenna.radiowaves.left.and.right"
        } else {
            return "exclamationmark.triangle"
        }
    }
    
    var body: some View {
        ZStack {
            CameraPreviewView(viewModel: viewModel)
                .ignoresSafeArea()
            
            VStack {
                // Status Bar
                HStack {
                    // Connection Status
                    HStack(spacing: 6) {
                        Circle()
                            .fill(statusColor)
                            .frame(width: 8, height: 8)
                        Text(statusMessage)
                            .font(.caption)
                            .foregroundColor(.white)
                    }
                    .padding(.horizontal, 10)
                    .padding(.vertical, 6)
                    .background(Color.black.opacity(0.7))
                    .cornerRadius(8)
                    
                    Spacer()
                    
                    // Network Signal Strength (solo cuando está conectando o transmitiendo)
                    if viewModel.streamState.isActive || viewModel.streamState == .connecting {
                        HStack(spacing: 4) {
                            Image(systemName: networkSignalIcon)
                                .font(.caption)
                            Text(viewModel.networkMonitor.connectionType)
                                .font(.caption)
                        }
                        .foregroundColor(.white)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 6)
                        .background(Color.black.opacity(0.7))
                        .cornerRadius(8)
                    }
                    
                    // Settings Button
                    Button(action: {
                        showSettings = true
                    }) {
                        Image(systemName: "gearshape.fill")
                            .font(.title3)
                            .foregroundColor(.white)
                            .padding(8)
                            .background(Color.black.opacity(0.7))
                            .clipShape(Circle())
                    }
                }
                .padding()
                
                Spacer()
                
                VStack(spacing: 20) {
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
                        
                        if viewModel.isTorchAvailable {
                            Button(action: {
                                viewModel.toggleTorch()
                            }) {
                                Image(systemName: viewModel.isTorchOn ? "bolt.fill" : "bolt.slash")
                                    .font(.title2)
                                    .foregroundColor(.white)
                                    .frame(width: 50, height: 50)
                                    .background(Color.black.opacity(0.6))
                                    .clipShape(Circle())
                            }
                        }
                        
                        Button(action: {
                            viewModel.toggleMicrophone()
                        }) {
                            Image(systemName: viewModel.isMicrophoneEnabled ? "mic.fill" : "mic.slash.fill")
                                .font(.title2)
                                .foregroundColor(.white)
                                .frame(width: 50, height: 50)
                                .background(Color.black.opacity(0.6))
                                .clipShape(Circle())
                        }
                    }
                    
                    // Go Live Button
                    Button(action: {
                        viewModel.startStream()
                    }) {
                        HStack {
                            Circle()
                                .fill(Color.red)
                                .frame(width: 12, height: 12)
                            Text("GO LIVE")
                                .fontWeight(.bold)
                                .font(.title3)
                        }
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.red)
                        .cornerRadius(12)
                    }
                    .padding(.horizontal)
                    .padding(.bottom)
                }
                .background(
                    LinearGradient(
                        gradient: Gradient(colors: [Color.clear, Color.black.opacity(0.7)]),
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
            }
        }
        .onAppear {
            print("📱 PreviewView appeared, starting preview...")
            viewModel.startPreview()
        }
        .fullScreenCover(isPresented: Binding(
            get: { viewModel.streamState.isActive },
            set: { _ in }
        )) {
            LiveView(viewModel: viewModel)
        }
        .sheet(isPresented: $viewModel.showDiagnostics) {
            DiagnosticsView(viewModel: viewModel)
        }
        .sheet(isPresented: $showSettings) {
            SettingsView(viewModel: viewModel)
        }
    }
}

struct CameraPreviewView: UIViewRepresentable {
    let viewModel: StreamViewModel
    
    func makeUIView(context: Context) -> MTHKView {
        let mthkView = MTHKView(frame: .zero)
        mthkView.backgroundColor = UIColor.black
        print("✅ MTHKView created")
        return mthkView
    }
    
    func updateUIView(_ uiView: MTHKView, context: Context) {
        // Attach stream cuando esté disponible (solo una vez)
        if !context.coordinator.hasAttachedStream {
            if let rtmpStream = viewModel.rtmpService.getRTMPStream() {
                DispatchQueue.main.async {
                    uiView.attachStream(rtmpStream)
                    context.coordinator.hasAttachedStream = true
                    print("✅ uiView.attachStream(stream) called")
                }
            }
        }
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator()
    }
    
    class Coordinator {
        var hasAttachedStream = false
    }
}
