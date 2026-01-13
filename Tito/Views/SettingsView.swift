import SwiftUI

struct SettingsView: View {
    @ObservedObject var viewModel: StreamViewModel
    @Environment(\.dismiss) var dismiss
    @State private var selectedDestination: StreamDestination
    
    init(viewModel: StreamViewModel) {
        self.viewModel = viewModel
        _selectedDestination = State(initialValue: KeychainService.shared.loadDestination())
    }
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Destino de Streaming")) {
                    ForEach(StreamDestination.allCases) { destination in
                        HStack {
                            Image(systemName: destination.icon)
                                .foregroundColor(.blue)
                                .frame(width: 30)
                            
                            Text(destination.displayName)
                                .font(.body)
                            
                            Spacer()
                            
                            if selectedDestination == destination {
                                Image(systemName: "checkmark")
                                    .foregroundColor(.blue)
                            }
                        }
                        .contentShape(Rectangle())
                        .onTapGesture {
                            selectedDestination = destination
                            KeychainService.shared.saveDestination(destination)
                        }
                    }
                }
                
                Section(header: Text("Información")) {
                    HStack {
                        Text("URL del Servidor")
                        Spacer()
                        Text(selectedDestination.serverURL)
                            .font(.caption)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.trailing)
                    }
                    
                    HStack {
                        Text("Stream Key")
                        Spacer()
                        Text(selectedDestination.streamKey)
                            .font(.caption)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.trailing)
                    }
                }
            }
            .navigationTitle("Configuración")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Listo") {
                        dismiss()
                    }
                }
            }
        }
    }
}
