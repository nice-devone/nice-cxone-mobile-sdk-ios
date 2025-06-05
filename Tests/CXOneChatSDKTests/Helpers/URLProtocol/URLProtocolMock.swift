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

class URLProtocolMock: URLProtocol {
    
    // MARK: - Properties

    static var handlers = [ProtocolMockHandler]()

    // MARK: - Methods

    override class func canInit(with request: URLRequest) -> Bool {
        handlers.contains { $0.canHandle(request: request) }
    }
    
    override class func canonicalRequest(for request: URLRequest) -> URLRequest {
        request
    }

    static func with<T>(handlers: ProtocolMockHandler..., perform: () async throws -> T) async throws -> T {
        Self.handlers = handlers
        defer { Self.handlers = [] }

        return try await perform()
    }

    override func startLoading() {
        do {
            guard let (response, data) = try Self.handlers.first(where: { $0.canHandle(request: request) })?.handle(request: request) else {
                client?.urlProtocol(
                    self,
                    didFailWithError: NSError(
                        domain: "URLProtoMock",
                        code: -1,
                        userInfo: [
                            NSLocalizedDescriptionKey: "unexpected request: \(request)",
                            "request": request
                        ]
                    )
                )
                return
            }

            client?.urlProtocol(self, didReceive: response, cacheStoragePolicy: .notAllowed)

            if let data = data {
                client?.urlProtocol(self, didLoad: data)
            }

            client?.urlProtocolDidFinishLoading(self)
        } catch {
            client?.urlProtocol(
                self,
                didFailWithError: NSError(
                    domain: "URLProtoMock",
                    code: -1,
                    userInfo: [
                        NSLocalizedDescriptionKey: "internal error: \(error)",
                        "request": request,
                        "cause": error
                    ]
                )
            )
        }
    }
    
    override func stopLoading() { }
}
