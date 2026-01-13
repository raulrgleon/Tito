import Foundation
import Security

class KeychainService {
    static let shared = KeychainService()
    
    private let service = "com.tito.app"
    private let serverURLKey = "restream_server_url"
    private let streamKeyKey = "restream_stream_key"
    private let destinationKey = "stream_destination"
    
    private init() {}
    
    func saveStreamConfig(_ config: StreamConfig) throws {
        try save(serverURLKey, value: config.serverURL)
        try save(streamKeyKey, value: config.streamKey)
    }
    
    func saveDestination(_ destination: StreamDestination) {
        if let data = destination.rawValue.data(using: .utf8) {
            let query: [String: Any] = [
                kSecClass as String: kSecClassGenericPassword,
                kSecAttrService as String: service,
                kSecAttrAccount as String: destinationKey,
                kSecValueData as String: data
            ]
            SecItemDelete(query as CFDictionary)
            SecItemAdd(query as CFDictionary, nil)
        }
    }
    
    func loadDestination() -> StreamDestination {
        if let data = load(destinationKey),
           let destination = StreamDestination(rawValue: data) {
            return destination
        }
        return .restream // Default
    }
    
    func loadStreamConfig() -> StreamConfig? {
        let destination = loadDestination()
        return StreamConfig(serverURL: destination.serverURL, streamKey: destination.streamKey)
    }
    
    func deleteStreamConfig() {
        delete(serverURLKey)
        delete(streamKeyKey)
    }
    
    private func save(_ key: String, value: String) throws {
        guard let data = value.data(using: .utf8) else {
            throw KeychainError.encodingError
        }
        
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: key,
            kSecValueData as String: data
        ]
        
        SecItemDelete(query as CFDictionary)
        
        let status = SecItemAdd(query as CFDictionary, nil)
        guard status == errSecSuccess else {
            throw KeychainError.saveError(status)
        }
    }
    
    private func load(_ key: String) -> String? {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: key,
            kSecReturnData as String: true,
            kSecMatchLimit as String: kSecMatchLimitOne
        ]
        
        var result: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &result)
        
        guard status == errSecSuccess,
              let data = result as? Data,
              let value = String(data: data, encoding: .utf8) else {
            return nil
        }
        
        return value
    }
    
    private func delete(_ key: String) {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: key
        ]
        
        SecItemDelete(query as CFDictionary)
    }
}

enum KeychainError: Error {
    case encodingError
    case saveError(OSStatus)
    case loadError(OSStatus)
}
