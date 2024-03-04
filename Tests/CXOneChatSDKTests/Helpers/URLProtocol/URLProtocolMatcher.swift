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

import Foundation

typealias URLProtocolMatcher = (URLRequest) -> Bool

func url(equals url: String, method: String = "GET") -> URLProtocolMatcher {
    { request in
        request.httpMethod == method && request.url?.absoluteString == url
    }
}

func url(matches url: String, method: String = "GET") -> URLProtocolMatcher {
    { request in
        request.httpMethod == method && request.url?.absoluteString.range(of: url, options: .regularExpression) != nil
    }
}
