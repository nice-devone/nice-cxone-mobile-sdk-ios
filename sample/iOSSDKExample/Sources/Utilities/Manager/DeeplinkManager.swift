//
// Copyright (c) 2021-2023. NICE Ltd. All rights reserved.
//
// Licensed under the NICE License;
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//    https://github.com/nice-devone/nice-cxone-mobile-sdk-ios/blob/main/LICENSE
//
// TO THE EXTENT PERMITTED BY APPLICABLE LAW, THE CXONE MOBILE SDK IS PROVIDED ON
// AN “AS IS” BASIS. NICE HEREBY DISCLAIMS ALL WARRANTIES AND CONDITIONS, EXPRESS
// OR IMPLIED, INCLUDING (WITHOUT LIMITATION) WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE, NON-INFRINGEMENT, AND TITLE.
//

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
