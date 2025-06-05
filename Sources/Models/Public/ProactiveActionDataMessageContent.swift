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

/// Represents info abount a content of a proactive action data message.
public struct ProactiveActionDataMessageContent {

    // MARK: - Properties

    /// Message content body
    public let bodyText: String?

    /// Message content headline
    public let headlineText: String?

    /// Message content secondary headline
    public let headlineSecondaryText: String?

    /// Message content image uri
    public let image: String?

    // MARK: - Init

    /// - Parameters:
    ///    - bodyText: The body.
    ///    - headlineText: The headline.
    ///    - headlineSecondaryText: The secondary headline.
    ///    - image: The image.
    public init(bodyText: String? = nil, headlineText: String? = nil, headlineSecondaryText: String? = nil, image: String? = nil) {
        self.bodyText = bodyText
        self.headlineText = headlineText
        self.headlineSecondaryText = headlineSecondaryText
        self.image = image
    }
}
