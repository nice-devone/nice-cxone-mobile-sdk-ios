//
// Copyright (c) 2021-2024. NICE Ltd. All rights reserved.
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
    let inboxAssignee: AgentDTO?
    
    /// The last agent that has been assigned to the thread
    let previousInboxAssignee: AgentDTO?
    
    /// Id of the contact in this thread
    let contactId: String?
    
    /// The token for the scroll position used to load more messages.
    let scrollToken: String
    
    /// The state of the thread
    var state: ChatThreadState
    
    /// Whether there are more messages to load in the thread.
    var hasMoreMessagesToLoad: Bool {
        !scrollToken.isEmpty
    }
}
