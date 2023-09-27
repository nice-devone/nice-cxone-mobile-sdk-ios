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

/// All information about a chat thread as well as the messages for the thread.
struct ChatThreadDTO {
    
    /// The unique id of the thread.
    let idOnExternalPlatform: UUID
    
    /// The name given to the thread (for multi-thread channels only).
    let threadName: String?
    
    /// The list of messages on the thread.
    var messages: [MessageDTO]
    
    /// The agent assigned in the thread.
    let threadAgent: AgentDTO?
    
    /// Whether more messages can be added to the thread (not archived) or otherwise (archived).
    let canAddMoreMessages: Bool
    
    /// Id of the contact in this thread
    let contactId: String?
    
    /// The token for the scroll position used to load more messages.
    let scrollToken: String
    
    /// Whether there are more messages to load in the thread.
    var hasMoreMessagesToLoad: Bool {
        !scrollToken.isEmpty
    }
}
