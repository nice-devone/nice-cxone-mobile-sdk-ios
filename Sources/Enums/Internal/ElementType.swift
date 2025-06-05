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

/// The different types of elements that can be present in the content of a message.
enum ElementType: String, Codable {
    
    // MARK: - Content Type
    
    /// Basic text.
    case text = "TEXT"
    
    /// A rich link message content type.
    case richLink = "RICH_LINK"
    
    /// A list picker message content type.
    case listPicker = "LIST_PICKER"
            
    /// A quick reply plugin/rich message to display.
    case quickReplies = "QUICK_REPLIES"
    
    // MARK: - TORM SubElements
    
    /// A reply button that the customer can press and send its text as a chat reply.
    case replyButton = "REPLY_BUTTON"
    
    case unknown
    
    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        let value = try container.decode(String.self)

        // Attempt to initialize from known values; otherwise, fall back to `unknown`
        self = ElementType(rawValue: value) ?? .unknown
    }
}
