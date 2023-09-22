import CXoneChatSDK
import Foundation

enum DeeplinkOption {
    
    /// com.incontact.mobileSDK.sample://threads?threadIdOnExternalPlatform=\(UUID)
    case thread(UUID)
}

protocol DeeplinkHandler {
    
    static func canOpenUrl(_ url: URL) -> Bool
    
    static func handleUrl(_ url: URL) -> DeeplinkOption?
}

class ThreadsDeeplinkHandler: DeeplinkHandler {
    
    static func canOpenUrl(_ url: URL) -> Bool {
        switch true {
        case canOpenThreadDetail(from: url):
            return true
        default:
            return false
        }
    }
    
    static func handleUrl(_ url: URL) -> DeeplinkOption? {
        if let option = handleThreadDetail(from: url) {
            return option
        } else {
            return nil
        }
    }
}

private extension ThreadsDeeplinkHandler {
    
    static func canOpenThreadDetail(from url: URL) -> Bool {
        url.absoluteString.contains("threads") && url.absoluteString.contains("idOnExternalPlatform")
    }
    
    static func handleThreadDetail(from url: URL) -> DeeplinkOption? {
        guard let threadId = url.getQueryValue(for: "idOnExternalPlatform"),
              let id = UUID(uuidString: threadId)
        else {
            return nil
        }
        
        return .thread(id)
    }
}

private extension URL {
    
    var queryParameters: [String: String]? {
        guard let components = URLComponents(url: self, resolvingAgainstBaseURL: true),
              let queryItems = components.queryItems
        else {
            return nil
        }
        
        return queryItems.reduce(into: [String: String]()) { (result, item) in
            result[item.name] = item.value
        }
    }
    
    func getQueryValue(for param: String) -> String? {
        guard let url = URLComponents(string: self.absoluteString) else {
          return nil
      }
        
      return url.queryItems?.first { $0.name == param }?.value
    }
}
