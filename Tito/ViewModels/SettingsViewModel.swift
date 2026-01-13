import Foundation
import Combine

class SettingsViewModel: ObservableObject {
    @Published var serverURL: String = ""
    @Published var streamKey: String = ""
    @Published var fullRTMPURL: String = ""
    @Published var useFullURL: Bool = false
    @Published var errorMessage: String?
    @Published var isValid: Bool = false
    
    private let keychainService = KeychainService.shared
    
    init() {
        loadSavedConfig()
    }
    
    func loadSavedConfig() {
        if let config = keychainService.loadStreamConfig() {
            serverURL = config.serverURL
            streamKey = config.streamKey
            fullRTMPURL = config.fullRTMPURL
            validate()
        }
    }
    
    func save() throws {
        let config: StreamConfig
        
        if useFullURL && !fullRTMPURL.isEmpty {
            config = StreamConfig(fullURL: fullRTMPURL)
        } else {
            config = StreamConfig(serverURL: serverURL, streamKey: streamKey)
        }
        
        guard config.isValid else {
            throw SettingsError.invalidConfiguration
        }
        
        try keychainService.saveStreamConfig(config)
        errorMessage = nil
        isValid = true
    }
    
    func validate() {
        if useFullURL {
            isValid = !fullRTMPURL.isEmpty && URL(string: fullRTMPURL) != nil
        } else {
            isValid = !serverURL.isEmpty && !streamKey.isEmpty
        }
        
        if !isValid {
            errorMessage = useFullURL ? "URL RTMP completa inválida" : "URL del servidor y clave de transmisión requeridas"
        } else {
            errorMessage = nil
        }
    }
}

enum SettingsError: Error {
    case invalidConfiguration
}
