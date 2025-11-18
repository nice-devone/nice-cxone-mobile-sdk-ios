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

/// Details required about an environment.
protocol EnvironmentDetails {

    /// The URL used for chat requests (channel config and attachment upload).
    var chatURL: String { get }

    /// The URL used for the WebSocket connection.
    var socketURL: String { get }
    
    /// The URL used for internal logging.
    var loggerURL: String { get }
}

// MARK: - Helpers

extension EnvironmentDetails {
    
    var chatServerUrl: URL? {
        URL(string: chatURL)
    }

    func webAnalyticsURL(brandId: Int) -> URL? {
        chatServerUrl.flatMap { URL(string: "/web-analytics/1.0/tenants/", relativeTo: $0) } / brandId
    }
}
