import Foundation

enum StreamDestination: String, CaseIterable, Identifiable {
    case restream = "Restream"
    case onestream = "Onestream"
    
    var id: String { rawValue }
    
    var displayName: String { rawValue }
    
    var serverURL: String {
        switch self {
        case .restream:
            return "rtmp://dallas.restream.io/live"
        case .onestream:
            return "rtmp://live.onestream.studio/live"
        }
    }
    
    var streamKey: String {
        switch self {
        case .restream:
            return "re_1922482_event610164eb199c42ebaae2ca64bb3e3e3c"
        case .onestream:
            return "live_4815384_0bgxkdcaa?auth=p_auth_4815384_2f0rhelwb"
        }
    }
    
    var icon: String {
        switch self {
        case .restream:
            return "play.rectangle.on.rectangle.fill"
        case .onestream:
            return "play.circle.fill"
        }
    }
}
