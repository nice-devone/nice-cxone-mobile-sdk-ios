//
// Copyright (c) 2021-2026. NICE Ltd. All rights reserved.
//
// Licensed under the NICE License;
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//    https://github.com/nice-devone/nice-cxone-mobile-sdk-ios/blob/main/LICENSE
//
// TO THE EXTENT PERMITTED BY APPLICABLE LAW, THE CXONE MOBILE SDK IS PROVIDED ON
// AN "AS IS" BASIS. NICE HEREBY DISCLAIMS ALL WARRANTIES AND CONDITIONS, EXPRESS
// OR IMPLIED, INCLUDING (WITHOUT LIMITATION) WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE, NON-INFRINGEMENT, AND TITLE.
//

import Foundation

/// A reply button rich message sub element.
public struct MessageReplyButton: Hashable, Equatable, Sendable {
    
    /// The text displayed in the button
    public let text: String
    
    /// A more detailed description of the option
    public let description: String?
    
    /// The postback of the button.
    ///
    /// Postback functionality should be used only for some extra automation processing (usually bots)
    /// in a way that the bot is not considering the content of the message but postback of the message
    /// where he can inject some better (more automatically readable) identifiers than what customer/agent
    /// can see in the UI as the content of the message.
    public let postback: String?
    
    /// The name of an image that will be displayed as part of the options​ (256 KiB)
    public let iconName: String?
    
    /// The URL of an image that will be displayed as part of the options​ (256 KiB)
    public let iconUrl: URL?
    
    /// The MIME type of an image that will be displayed as part of the options​ (256 KiB)
    public let iconMimeType: String?

    // MARK: - Init

    /// Creates a `MessageReplyButton`.
    ///
    /// - Parameters:
    ///   - text: The button label shown to the user.
    ///   - description: Optional secondary description displayed alongside the button.
    ///   - postback: Optional opaque payload echoed back to the agent/bot when the user taps the button.
    ///   - iconName: Filename of an optional icon (256 KiB cap).
    ///   - iconUrl: URL of an optional icon (256 KiB cap).
    ///   - iconMimeType: MIME type of the optional icon.
    public init(text: String, description: String? = nil, postback: String? = nil, iconName: String? = nil, iconUrl: URL? = nil, iconMimeType: String? = nil) {
        self.text = text
        self.description = description
        self.postback = postback
        self.iconName = iconName
        self.iconUrl = iconUrl
        self.iconMimeType = iconMimeType
    }
}
