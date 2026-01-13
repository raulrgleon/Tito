import Foundation

struct StreamConfig: Codable {
    var serverURL: String
    var streamKey: String
    
    var fullRTMPURL: String {
        if serverURL.isEmpty || streamKey.isEmpty {
            return ""
        }
        return "\(serverURL)/\(streamKey)"
    }
    
    init(serverURL: String = "", streamKey: String = "") {
        self.serverURL = serverURL
        self.streamKey = streamKey
    }
    
    init(fullURL: String) {
        if let url = URL(string: fullURL),
           let scheme = url.scheme,
           scheme == "rtmp" {
            let pathComponents = url.pathComponents.filter { $0 != "/" }
            if let last = pathComponents.last {
                self.streamKey = last
                var urlString = "\(scheme)://\(url.host ?? "")"
                if let port = url.port {
                    urlString += ":\(port)"
                }
                if pathComponents.count > 1 {
                    urlString += "/" + pathComponents.dropLast().joined(separator: "/")
                }
                self.serverURL = urlString
            } else {
                self.serverURL = fullURL
                self.streamKey = ""
            }
        } else {
            self.serverURL = fullURL
            self.streamKey = ""
        }
    }
    
    var isValid: Bool {
        !serverURL.isEmpty && !streamKey.isEmpty
    }
}
