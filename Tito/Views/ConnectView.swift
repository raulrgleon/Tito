import SwiftUI

struct ConnectView: View {
    @StateObject private var viewModel = SettingsViewModel()
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        NavigationView {
            Form {
                Section {
                    Toggle("Usar URL RTMP completa", isOn: $viewModel.useFullURL)
                        .onChange(of: viewModel.useFullURL) { _ in
                            viewModel.validate()
                        }
                }
                
                if viewModel.useFullURL {
                    Section(header: Text("URL RTMP Completa")) {
                        TextField("rtmp://...", text: $viewModel.fullRTMPURL)
                            .autocapitalization(.none)
                            .autocorrectionDisabled()
                            .onChange(of: viewModel.fullRTMPURL) { _ in
                                viewModel.validate()
                            }
                    }
                } else {
                    Section(header: Text("Servidor")) {
                        TextField("rtmp://live.restream.io/live", text: $viewModel.serverURL)
                            .autocapitalization(.none)
                            .autocorrectionDisabled()
                            .onChange(of: viewModel.serverURL) { _ in
                                viewModel.validate()
                            }
                    }
                    
                    Section(header: Text("Clave de Transmisión")) {
                        SecureField("Tu clave de Restream", text: $viewModel.streamKey)
                            .autocapitalization(.none)
                            .autocorrectionDisabled()
                            .onChange(of: viewModel.streamKey) { _ in
                                viewModel.validate()
                            }
                    }
                }
                
                if let error = viewModel.errorMessage {
                    Section {
                        Text(error)
                            .foregroundColor(.red)
                            .font(.caption)
                    }
                }
                
                Section(footer: Text("Tus credenciales se guardan de forma segura en el Keychain de iOS.")) {
                    Button(action: {
                        do {
                            try viewModel.save()
                            // Notificar que se completó la configuración
                            NotificationCenter.default.post(name: NSNotification.Name("StreamConfigSaved"), object: nil)
                            dismiss()
                        } catch {
                            viewModel.errorMessage = "Error al guardar la configuración"
                        }
                    }) {
                        HStack {
                            Spacer()
                            Text("Guardar")
                                .fontWeight(.semibold)
                            Spacer()
                        }
                    }
                    .disabled(!viewModel.isValid)
                }
            }
            .navigationTitle("Conectar Restream")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}
