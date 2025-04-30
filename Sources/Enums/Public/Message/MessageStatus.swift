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

/// Representation of the delivery and read status of a chat message
///
/// This enum is designed for categorizing the status of chat messages,
/// providing information about whether a message has been sent, delivered, or seen by the recipient.
/// It is valuable for tracking and displaying the communication status in messaging and chat applications.
public enum MessageStatus: Comparable {
    
    /// Indicates that the message has been sent but not yet delivered.
    case sent
    
    /// Indicates that the message has been delivered to the recipient.
    case delivered
    
    /// Indicates that the message has been seen or read by the recipient.
    case seen
    
    /// Indicates that the message has not been sent properly.
    case failed
}
