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

/// All information about a chat thread as well as the messages for the thread.
public class ChatThread: Identifiable {

    /// The unique id of the thread. Refers to the `idOnExternalPlatform`.
    public let id: UUID
    
    /// The name given to the thread (for multi-thread channels only).
    public var name: String?
    
    /// The list of messages on the thread.
    public var messages: [Message]

    /// The agent assigned in the thread.
    public var assignedAgent: Agent?
    
    /// The last agent that has been assigned to the thread
    ///
    /// This attribute can be used to get the previously assigned agent back to the thread after unassignment.
    public var lastAssignedAgent: Agent?
    
    /// Id of the contact in this thread
    var contactId: String?
    
    /// The token for the scroll position used to load more messages.
    public var scrollToken: String
    
    /// The thread state
    public var state: ChatThreadState
    
    /// Whether there are more messages to load in the thread.
    public var hasMoreMessagesToLoad: Bool {
        !scrollToken.isEmpty
    }

    /// The position in the queue
    public var positionInQueue: Int?
    
    // MARK: - Init
    
    init(
        id: UUID,
        state: ChatThreadState,
        name: String? = nil,
        messages: [Message] = [],
        assignedAgent: Agent? = nil,
        lastAssignedAgent: Agent? = nil,
        contactId: String? = nil,
        scrollToken: String = "",
        positionInQueue: Int? = nil
    ) {
        self.id = id
        self.state = state
        self.name = name
        self.messages = messages
        self.assignedAgent = assignedAgent
        self.lastAssignedAgent = lastAssignedAgent
        self.contactId = contactId
        self.scrollToken = scrollToken
        self.positionInQueue = positionInQueue
    }
}

// MARK: - Helpers

extension ChatThread {
    
    func merge(messages inserted: [Message]) {
        inserted.forEach { message in
            if let index = index(of: message) {
                messages[index] = message
            } else {
                messages.append(message)
            }
        }
        messages.sort { $0.createdAt < $1.createdAt }
    }

    private func index(of message: Message) -> Int? {
        messages.firstIndex {
            $0.id == message.id
        }
    }
    
    func updated(from data: ThreadRecoveredEventPostbackDataDTO) {
        updated(
            messages: data.messages,
            inboxAssignee: data.inboxAssignee.map(AgentMapper.map),
            previousInboxAssignee: nil,
            name: data.thread.threadName,
            contactId: data.consumerContact.id,
            scrollToken: data.messagesScrollToken,
            state: data.thread.canAddMoreMessages ? .ready : .closed
        )
    }
    
    func updated(from data: LiveChatRecoveredPostbackDataDTO) {
        let filteredMessages = data.messages.filter { message in
            guard case .text(let payload) = message.contentType else {
                return true
            }
            
            // Do not append content of `beginLiveChatConversationMessage`
            return payload.text != ChatThreadService.beginLiveChatConversationMessage
        }
        
        updated(
            messages: filteredMessages,
            inboxAssignee: data.inboxAssignee.map(AgentMapper.map),
            previousInboxAssignee: data.previousInboxAssignee.map(AgentMapper.map),
            name: data.thread.threadName,
            contactId: data.contact.id,
            scrollToken: data.messagesScrollToken,
            state: data.thread.canAddMoreMessages
                ? data.inboxAssignee == nil ? .loaded : .ready
                : .closed,
            // Clear the position in queue if an `inboxAssignee` exists
            positionInQueue: data.inboxAssignee == nil
                ? self.positionInQueue
                : nil
        )
    }
    
    private func updated(
        messages: [MessageDTO]? = nil,
        inboxAssignee: Agent? = nil,
        previousInboxAssignee: Agent? = nil,
        name: String? = nil,
        contactId: String? = nil,
        scrollToken: String? = nil,
        state: ChatThreadState? = nil,
        positionInQueue: Int? = nil
    ) {
        self.state = state ?? self.state
        self.name = name ?? self.name
        self.assignedAgent = inboxAssignee ?? self.assignedAgent
        self.lastAssignedAgent = previousInboxAssignee ?? self.lastAssignedAgent
        self.contactId = contactId ?? self.contactId
        self.scrollToken = scrollToken ?? self.scrollToken
        self.positionInQueue = positionInQueue ?? self.positionInQueue
        
        if let messages {
            self.merge(messages: messages.map(MessageMapper.map))
        }
    }
}
