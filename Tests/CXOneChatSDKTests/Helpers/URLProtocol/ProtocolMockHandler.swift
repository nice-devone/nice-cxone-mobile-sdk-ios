//
// Copyright (c) 2021-2024. NICE Ltd. All rights reserved.
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

struct ProtocolMockHandler {
    
    // MARK: - Properties

    let canHandle: URLProtocolMatcher
    let handle: URLProtocolAction

    // MARK: - Methods

    func canHandle(request: URLRequest) -> Bool {
        canHandle(request)
    }

    func handle(request: URLRequest) throws -> (HTTPURLResponse, Data?) {
        try handle(request)
    }
}

func accept(
    _ matcher: @escaping URLProtocolMatcher,
    body handler: @escaping URLProtocolAction
) -> ProtocolMockHandler {
    ProtocolMockHandler(canHandle: matcher, handle: handler)
}