//
// Copyright (c) 2021-2025. NICE Ltd. All rights reserved.
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

import Foundation

#if DEBUG
class LenientURLSessionDelegate: NSObject, URLSessionDelegate {
    /// Allows for inspecting traffic in tools like Proxyman or CharlesApp.
    public func urlSession(
        _ session: URLSession,
        didReceive challenge: URLAuthenticationChallenge,
        completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void
    ) {
        guard let serverTrust = challenge.protectionSpace.serverTrust else {
            LogManager.warning("Server trust error")
            return
        }

        completionHandler(.useCredential, URLCredential(trust: serverTrust))
    }
}

extension URLSession {
    static func lenient(configuration: URLSessionConfiguration = .default) -> URLSession {
        URLSession(configuration: configuration, delegate: LenientURLSessionDelegate(), delegateQueue: OperationQueue())
    }
}
#endif
