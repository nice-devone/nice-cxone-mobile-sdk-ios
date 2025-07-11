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

/// The different types of actions for an event.
enum EventActionType: String, Codable {
    
    /// The customer is registering for chat access.
    ///
    /// - Warning: This action is used only during the `Authorize`.
    case register
    
    /// The customer is interacting with something in the chat window.
    case chatWindowEvent
    
    /// The customer is making an outbound action.
    case outbound
    
    /// The socket is sending a message to verify the connection.
    case heartbeat
}
