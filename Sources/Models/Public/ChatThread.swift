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
public struct ChatThread {

    /// The unique id of the thread. Refers to the `idOnExternalPlatform`.
    public let id: UUID
    
    /// The name given to the thread (for multi-thread channels only).
    public var name: String?
    
    /// The list of messages on the thread.
    public var messages = [Message]()

    /// The agent assigned in the thread.
    public var assignedAgent: Agent?
    
    /// Id of the contact in this thread
    var contactId: String?
    
    /// The token for the scroll position used to load more messages.
    public var scrollToken: String = ""
    
    /// The thread state
    public var state: ChatThreadState
    
    /// Whether there are more messages to load in the thread.
    public var hasMoreMessagesToLoad: Bool {
        !scrollToken.isEmpty
    }
}

extension ChatThread {
    private func index(of message: Message) -> Int? {
        messages.firstIndex {
            $0.id == message.id
        }
    }

    mutating func merge(messages inserted: [Message]) {
        inserted.forEach { message in
            if let index = index(of: message) {
                messages[index] = message
            } else {
                messages.append(message)
            }
        }
        messages.sort { $0.createdAt < $1.createdAt }
    }

    mutating func insert(message: Message) {
        merge(messages: [message])
    }
}
