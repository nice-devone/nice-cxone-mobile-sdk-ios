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

/// Represents outbound message which is send to an agent.
public struct OutboundMessage {
    
    // MARK: - Properties
    
    /// The text of the message.
    public let text: String
    
    /// The list of attachments. May contain single attachment.
    public let attachments: [ContentDescriptor]
    
    /// The postback used within rich content messages.
    ///
    /// This value must be provided when sending answer prompt with a rich content type defined in ``MessageContentType``.
    public let postback: String?
    
    // MARK: - Init
    
    /// - Parameters:
    ///   - text: The text of the message.
    ///   - attachments: The list of attachments. May contain single attachment.
    ///   - postback: The postback used within rich content messages.
    public init(text: String, attachments: [ContentDescriptor] = [], postback: String? = nil) {
        self.text = text
        self.attachments = attachments
        self.postback = postback
    }
}
