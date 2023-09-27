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

/// Represents info abount a content of a proactive action data message.
struct ProactiveActionDataMessageContentDTO: Codable {

    // MARK: - Properties

    let bodyText: String?

    let headlineText: String?

    let headlineSecondaryText: String?

    let image: String?

    // MARK: - Init

    /// - Parameters:
    ///    - bodyText: The body.
    ///    - headlineText: The headline.
    ///    - headlineSecondaryText: The secondary headline.
    ///    - image: The image.
    init(bodyText: String?, headlineText: String?, headlineSecondaryText: String?, image: String?) {
        self.bodyText = bodyText
        self.headlineText = headlineText
        self.headlineSecondaryText = headlineSecondaryText
        self.image = image
    }
}
