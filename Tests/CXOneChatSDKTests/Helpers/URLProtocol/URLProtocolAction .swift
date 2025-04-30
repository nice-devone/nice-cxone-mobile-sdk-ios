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

typealias URLProtocolAction = (URLRequest)  throws -> (HTTPURLResponse, Data?)

func string(_ string: String, code: Int = 200) -> URLProtocolAction {
    lazy var data = string.data(using: .utf8)

    return { request in
        (
            HTTPURLResponse(
                url: request.url!,
                statusCode: code,
                httpVersion: nil,
                headerFields: nil
            )!,
            data
        )
    }
}

func data(_ data: Data, code: Int = 200) -> URLProtocolAction {
    { request in
        (
            HTTPURLResponse(
                url: request.url!,
                statusCode: code,
                httpVersion: nil,
                headerFields: nil
            )!,
            data
        )
    }
}

func resource(_ name: String, type: String, code: Int = 200) -> URLProtocolAction {
    { request in
        let url = URL(forResource: name, type: type)

        return (
            HTTPURLResponse(
                url: request.url!,
                statusCode: code,
                httpVersion: nil,
                headerFields: nil
            )!,
            try Data(contentsOf: url)
        )
    }
}

func none(code: Int = 200) -> URLProtocolAction {
    { request in
        (
            HTTPURLResponse(
                url: request.url!,
                statusCode: code,
                httpVersion: nil,
                headerFields: nil
            )!,
            nil
        )
    }
}
