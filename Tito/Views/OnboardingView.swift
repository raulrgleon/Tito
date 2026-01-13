import SwiftUI

struct OnboardingView: View {
    @EnvironmentObject var viewModel: OnboardingViewModel
    @State private var currentPage = 0
    @State private var showConnectView = false
    
    var body: some View {
        ZStack {
            TabView(selection: $currentPage) {
                OnboardingPageView(
                    title: "Transmite desde tu iPhone",
                    description: "Conecta tu iPhone a Restream y transmite a todas las plataformas simultáneamente.",
                    imageName: "iphone",
                    pageIndex: 0,
                    showButton: false
                )
                .tag(0)
                
                OnboardingPageView(
                    title: "Configuración simple",
                    description: "Solo necesitas tu URL de servidor y clave de transmisión de Restream.",
                    imageName: "gear",
                    pageIndex: 1,
                    showButton: false
                )
                .tag(1)
                
                OnboardingPageView(
                    title: "Listo para transmitir",
                    description: "Presiona 'Conectar Restream' para comenzar.",
                    imageName: "video.fill",
                    pageIndex: 2,
                    showButton: true,
                    buttonAction: {
                        showConnectView = true
                    }
                )
                .tag(2)
            }
            .tabViewStyle(.page)
            .indexViewStyle(.page(backgroundDisplayMode: .always))
        }
        .sheet(isPresented: $showConnectView) {
            ConnectView()
                .onDisappear {
                    // Verificar si se guardó la configuración
                    if KeychainService.shared.loadStreamConfig() != nil {
                        viewModel.hasCompletedOnboarding = true
                    }
                }
        }
        .onReceive(NotificationCenter.default.publisher(for: NSNotification.Name("StreamConfigSaved"))) { _ in
            // Actualizar el estado cuando se guarda la configuración
            viewModel.hasCompletedOnboarding = true
        }
        .onAppear {
            // Si ya hay configuración guardada, saltar el onboarding
            if KeychainService.shared.loadStreamConfig() != nil {
                viewModel.hasCompletedOnboarding = true
            }
        }
    }
}

struct OnboardingPageView: View {
    let title: String
    let description: String
    let imageName: String
    let pageIndex: Int
    let showButton: Bool
    var buttonAction: (() -> Void)? = nil
    
    var body: some View {
        VStack(spacing: 40) {
            Spacer()
            
            Image(systemName: imageName)
                .font(.system(size: 80))
                .foregroundColor(.blue)
            
            VStack(spacing: 16) {
                Text(title)
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .multilineTextAlignment(.center)
                
                Text(description)
                    .font(.body)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
            }
            
            Spacer()
            
            if showButton, let action = buttonAction {
                Button(action: action) {
                    Text("Conectar Restream")
                        .fontWeight(.semibold)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .cornerRadius(12)
                }
                .padding(.horizontal, 40)
                .padding(.bottom, 60)
            }
        }
        .padding()
    }
}
