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

/// All information about a chat thread as well as the messages for the thread.
public struct ChatThread: Identifiable, Sendable {

    /// The unique id of the thread. Refers to the `idOnExternalPlatform`.
    ///
    /// The canonical, case-preserving identifier of the thread as provided by the backend.
    /// Stores the **exact** value from the backend, without altering case.
    public let id: String
    
    /// The name given to the thread (for multi-thread channels only).
    public let name: String?

    /// The list of messages on the thread.
    public let messages: [Message]

    /// The agent assigned in the thread.
    public let assignedAgent: Agent?

    /// The last agent that has been assigned to the thread
    ///
    /// This attribute can be used to get the previously assigned agent back to the thread after unassignment.
    public let lastAssignedAgent: Agent?

    /// The agent that owns the case — the last agent it was actually assigned to.
    ///
    /// Unlike ``assignedAgent`` (the inbox assignee, i.e. who currently has the case open), the owner
    /// persists across unassignment. It is populated from the backend on thread recovery and is used to
    /// determine that the customer has already been engaged by an agent (and is therefore no longer in the queue).
    public let ownerAssignee: Agent?

    /// The identifier of the contact associated with this thread, as provided by the backend.
    ///
    /// May be `nil` when the thread has no associated contact yet — for example, a thread constructed
    /// locally before the SDK has populated it. This value is read-only: it is supplied by the SDK and
    /// cannot be set when constructing a `ChatThread` directly.
    public let contactId: String?

    /// The token for the scroll position used to load more messages.
    public let scrollToken: String

    /// The thread state
    public let state: ChatThreadState

    /// Whether there are more messages to load in the thread.
    public var hasMoreMessagesToLoad: Bool {
        !scrollToken.isEmpty
    }

    /// The position in the queue
    public let positionInQueue: Int?

    // MARK: - Init

    /// Creates a `ChatThread` value, typically when synthesising threads for tests, previews, or seeding state.
    ///
    /// Production code receives `ChatThread` instances from the SDK via the
    /// ``ChatProvider/threads`` provider and the ``ChatEvent/threadUpdated(_:)`` /
    /// ``ChatEvent/threadsUpdated(_:)`` events — direct construction is rarely needed.
    ///
    /// - Parameters:
    ///   - id: The backend-canonical thread identifier (`idOnExternalPlatform`).
    ///   - state: The current state of the thread.
    ///   - name: Display name (multi-thread channels only).
    ///   - messages: The known messages on the thread.
    ///   - assignedAgent: Currently assigned agent, if any.
    ///   - lastAssignedAgent: Previously assigned agent, useful for re-assignment flows.
    ///   - ownerAssignee: The agent that owns the case, persisted across unassignment.
    ///   - scrollToken: Cursor for paging older messages; empty means no more history.
    ///   - positionInQueue: Position in queue for live-chat scenarios.
    public init(
        id: String,
        state: ChatThreadState,
        name: String? = nil,
        messages: [Message] = [],
        assignedAgent: Agent? = nil,
        lastAssignedAgent: Agent? = nil,
        ownerAssignee: Agent? = nil,
        scrollToken: String = "",
        positionInQueue: Int? = nil
    ) {
        self.id = id
        self.state = state
        self.name = name
        self.messages = messages
        self.assignedAgent = assignedAgent
        self.lastAssignedAgent = lastAssignedAgent
        self.ownerAssignee = ownerAssignee
        self.contactId = nil
        self.scrollToken = scrollToken
        self.positionInQueue = positionInQueue
    }

    init(
        id: String,
        state: ChatThreadState,
        name: String? = nil,
        messages: [Message] = [],
        assignedAgent: Agent? = nil,
        lastAssignedAgent: Agent? = nil,
        ownerAssignee: Agent? = nil,
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
        self.ownerAssignee = ownerAssignee
        self.contactId = contactId
        self.scrollToken = scrollToken
        self.positionInQueue = positionInQueue
    }
}

// MARK: - Helpers

extension ChatThread {

    /// Merges new messages into the thread and returns a new ChatThread instance.
    ///
    /// - Parameter inserted: The messages to merge into the thread.
    /// - Returns: A new ChatThread with the merged messages, sorted by creation date.
    func merged(with inserted: [Message]) -> ChatThread {
        var updatedMessages = messages

        inserted.forEach { message in
            if let index = updatedMessages.firstIndex(where: { $0.id == message.id }) {
                updatedMessages[index] = message
            } else {
                updatedMessages.append(message)
            }
        }

        updatedMessages.sort { $0.createdAt < $1.createdAt }

        return ChatThread(
            id: id,
            state: state,
            name: name,
            messages: updatedMessages,
            assignedAgent: assignedAgent,
            lastAssignedAgent: lastAssignedAgent,
            ownerAssignee: ownerAssignee,
            contactId: contactId,
            scrollToken: scrollToken,
            positionInQueue: positionInQueue
        )
    }

    /// Creates a copy of this ChatThread with updated properties from `ThreadRecoveredEventPostbackDataDTO`.
    ///
    /// Convenience wrapper around ``merging(messages:inboxAssignee:previousInboxAssignee:ownerAssignee:name:contactId:scrollToken:state:positionInQueue:)``
    /// that destructures the recovery payload and applies it to the receiver. Messages from the
    /// payload are filtered (begin-live-chat-conversation / unsupported-message-type-answer /
    /// inactivity-popup-answer text messages, and `.inactivityPopup` messages, are dropped) and
    /// merged into the existing message list; remaining fields follow the same
    /// "nil means keep existing" rule as the underlying `merging(...)` method.
    ///
    /// - Parameter data: The data to use for updating the thread.
    /// - Returns: A new ChatThread with the payload merged in.
    func merging(from data: ThreadRecoveredEventPostbackDataDTO) -> ChatThread {
        merging(
            messages: data.messages,
            inboxAssignee: data.inboxAssignee.map(AgentMapper.map),
            previousInboxAssignee: nil,
            name: data.thread.threadName,
            contactId: data.consumerContact.id,
            scrollToken: data.messagesScrollToken,
            state: data.thread.canAddMoreMessages ? .ready : .closed
        )
    }

    /// Creates a copy of this ChatThread with updated properties from `LiveChatRecoveredPostbackDataDTO`.
    ///
    /// Convenience wrapper around ``merging(messages:inboxAssignee:previousInboxAssignee:ownerAssignee:name:contactId:scrollToken:state:positionInQueue:)``
    /// that destructures the live-chat recovery payload and applies it to the receiver. State is
    /// derived as `.loaded` / `.ready` / `.closed` based on `canAddMoreMessages` and whether an
    /// assignee is present; `positionInQueue` is explicitly cleared when an `inboxAssignee` is
    /// assigned. Messages from the payload are filtered and merged as in the underlying
    /// `merging(...)` method.
    ///
    /// - Parameter data: The data to use for updating the thread.
    /// - Returns: A new ChatThread with the payload merged in.
    func merging(from data: LiveChatRecoveredPostbackDataDTO) -> ChatThread {
        let merged = merging(
            messages: data.messages,
            inboxAssignee: data.inboxAssignee.map(AgentMapper.map),
            previousInboxAssignee: data.previousInboxAssignee.map(AgentMapper.map),
            ownerAssignee: data.ownerAssignee.map(AgentMapper.map),
            name: data.thread.threadName,
            contactId: data.contact.id,
            scrollToken: data.messagesScrollToken,
            state: data.thread.canAddMoreMessages ? .ready : .closed,
            // Clear the position in queue if an `inboxAssignee` exists
            positionInQueue: data.inboxAssignee == nil
                ? self.positionInQueue
                : nil
        )

        // A recovery payload is an authoritative snapshot: a nil `inboxAssignee` means the thread is currently
        // unassigned, so a previously stored `assignedAgent` must be cleared. The generic `merging(...)` treats
        // nil as "keep existing" and cannot express this, so rebuild via the initializer for the clear case.
        // The case owner (`ownerAssignee`) and previous assignee (`lastAssignedAgent`) are preserved.
        guard data.inboxAssignee == nil else {
            return merged
        }

        return ChatThread(
            id: merged.id,
            state: merged.state,
            name: merged.name,
            messages: merged.messages,
            assignedAgent: nil,
            lastAssignedAgent: merged.lastAssignedAgent,
            ownerAssignee: merged.ownerAssignee,
            contactId: merged.contactId,
            scrollToken: merged.scrollToken,
            positionInQueue: merged.positionInQueue
        )
    }

    /// Creates a copy of this ChatThread by **merging** the supplied fields and DTO messages into
    /// the receiver.
    ///
    /// Use this when folding server-side data (`MessageDTO`s and partial field updates) into the
    /// existing thread — for example when handling a recovery, metadata-load, or message-created
    /// event. Messages are filtered (begin-live-chat-conversation / unsupported-message-type-answer /
    /// inactivity-popup-answer text messages, and `.inactivityPopup` messages, are dropped) and
    /// **merged** into the existing message list via ``merged(with:)`` rather than replacing it.
    ///
    /// All field parameters follow the "nil means keep existing" rule — passing `nil` retains the
    /// receiver's current value. If you need to *clear* a field (set it to `nil`), construct a
    /// `ChatThread` via its initializer instead; this method has no way to express "set to nil."
    ///
    /// Contrast with ``copy(state:name:messages:assignedAgent:lastAssignedAgent:ownerAssignee:contactId:scrollToken:positionInQueue:)``,
    /// which takes already-mapped `Message` objects and **replaces** the message list outright
    /// rather than merging.
    ///
    /// - Parameters:
    ///   - messages: Server DTOs to filter and merge into the existing list. If nil, keeps existing messages.
    ///   - inboxAssignee: New assigned agent. If nil, keeps existing assignedAgent.
    ///   - previousInboxAssignee: New last assigned agent. If nil, keeps existing lastAssignedAgent.
    ///   - ownerAssignee: New owner assignee. If nil, keeps existing ownerAssignee.
    ///   - name: New thread name. If nil, keeps existing name.
    ///   - contactId: New contact ID. If nil, keeps existing contactId.
    ///   - scrollToken: New scroll token. If nil, keeps existing scrollToken.
    ///   - state: New thread state. If nil, keeps existing state.
    ///   - positionInQueue: New position in queue. If nil, keeps existing positionInQueue.
    /// - Returns: A new ChatThread with the merged updates applied.
    func merging(
        messages: [MessageDTO]? = nil,
        inboxAssignee: Agent? = nil,
        previousInboxAssignee: Agent? = nil,
        ownerAssignee: Agent? = nil,
        name: String? = nil,
        contactId: String? = nil,
        scrollToken: String? = nil,
        state: ChatThreadState? = nil,
        positionInQueue: Int? = nil
    ) -> ChatThread {
        let filteredMessages = messages?.filter { message in
            switch message.contentType {
            case .text(let payload):
                // Do not append content of the begin live chat conversation message, unsupported message type answer, or inactivity popup answer
               return payload.parameters.hasOneOf(.isBeginLiveChatConversation, .isUnsupportedMessageTypeAnswer, .isInactivityPopupAnswer) == false
            case .inactivityPopup:
                // Filter out inactivity popup messages (they are handled separately)
                return false
            default:
                return true
            }
        }

        var result = ChatThread(
            id: id,
            state: state ?? self.state,
            name: name ?? self.name,
            messages: self.messages,
            assignedAgent: inboxAssignee ?? self.assignedAgent,
            lastAssignedAgent: previousInboxAssignee ?? self.lastAssignedAgent,
            ownerAssignee: ownerAssignee ?? self.ownerAssignee,
            contactId: contactId ?? self.contactId,
            scrollToken: scrollToken ?? self.scrollToken,
            positionInQueue: positionInQueue ?? self.positionInQueue
        )

        if let filteredMessages {
            result = result.merged(with: filteredMessages.compactMap(MessageMapper.map))
        }

        return result
    }

    /// Creates a copy of this ChatThread with a new message appended.
    ///
    /// - Parameter message: The message to append.
    /// - Returns: A new ChatThread with the message appended.
    func appending(message: Message) -> ChatThread {
        ChatThread(
            id: id,
            state: state,
            name: name,
            messages: messages + [message],
            assignedAgent: assignedAgent,
            lastAssignedAgent: lastAssignedAgent,
            ownerAssignee: ownerAssignee,
            contactId: contactId,
            scrollToken: scrollToken,
            positionInQueue: positionInQueue
        )
    }

    /// Creates a copy of this ChatThread with the last message removed.
    ///
    /// - Returns: A new ChatThread with the last message removed.
    func removingLastMessage() -> ChatThread {
        ChatThread(
            id: id,
            state: state,
            name: name,
            messages: Array(messages.dropLast()),
            assignedAgent: assignedAgent,
            lastAssignedAgent: lastAssignedAgent,
            ownerAssignee: ownerAssignee,
            contactId: contactId,
            scrollToken: scrollToken,
            positionInQueue: positionInQueue
        )
    }

    /// Creates a copy of this ChatThread with the last message removed, only if it matches the expected ID.
    ///
    /// - Parameter expectedId: The expected ID of the last message. If the last message doesn't match, returns self unchanged.
    /// - Returns: A new ChatThread with the last message removed if ID matches, otherwise returns self.
    func removingLastMessage(ifMatches expectedId: String) -> ChatThread {
        guard let lastMessage = messages.last, lastMessage.id == expectedId else {
            return self
        }

        return ChatThread(
            id: id,
            state: state,
            name: name,
            messages: Array(messages.dropLast()),
            assignedAgent: assignedAgent,
            lastAssignedAgent: lastAssignedAgent,
            ownerAssignee: ownerAssignee,
            contactId: contactId,
            scrollToken: scrollToken,
            positionInQueue: positionInQueue
        )
    }

    /// Replaces a message with the given ID with a new message.
    ///
    /// - Parameters:
    ///   - messageId: The ID of the message to replace.
    ///   - newMessage: The new message to use as replacement.
    /// - Returns: A new ChatThread with the message replaced, or self if message ID not found.
    func replacingMessage(withId messageId: String, with newMessage: Message) -> ChatThread {
        guard let index = messages.firstIndex(where: { $0.id == messageId }) else {
            return self
        }

        var updatedMessages = messages
        updatedMessages[index] = newMessage

        return ChatThread(
            id: id,
            state: state,
            name: name,
            messages: updatedMessages,
            assignedAgent: assignedAgent,
            lastAssignedAgent: lastAssignedAgent,
            ownerAssignee: ownerAssignee,
            contactId: contactId,
            scrollToken: scrollToken,
            positionInQueue: positionInQueue
        )
    }

    /// Creates a copy of this ChatThread with one or more fields replaced.
    ///
    /// Use this for plain per-field tweaks where you already hold the values to write — e.g.
    /// `thread.copy(state: .closed)` or `thread.copy(assignedAgent: agent)`. The `messages`
    /// parameter, when non-nil, **replaces** the existing message list outright; it takes
    /// already-mapped ``Message`` objects.
    ///
    /// All parameters follow the "nil means keep existing" rule — passing `nil` retains the
    /// receiver's current value. If you need to *clear* a field (set it to `nil`), construct a
    /// `ChatThread` via its initializer instead; this method has no way to express "set to nil."
    ///
    /// Contrast with ``merging(messages:inboxAssignee:previousInboxAssignee:ownerAssignee:name:contactId:scrollToken:state:positionInQueue:)``,
    /// which takes raw `MessageDTO`s from the server, filters out platform noise, and **merges**
    /// them into the existing message list rather than replacing it.
    ///
    /// - Parameters:
    ///   - state: New thread state. If nil, keeps existing state.
    ///   - name: New thread name. If nil, keeps existing name.
    ///   - messages: Replacement message list. If nil, keeps existing messages.
    ///   - assignedAgent: New assigned agent. If nil, keeps existing assignedAgent.
    ///   - lastAssignedAgent: New last assigned agent. If nil, keeps existing lastAssignedAgent.
    ///   - ownerAssignee: New owner assignee. If nil, keeps existing ownerAssignee.
    ///   - contactId: New contact ID. If nil, keeps existing contactId.
    ///   - scrollToken: New scroll token. If nil, keeps existing scrollToken.
    ///   - positionInQueue: New position in queue. If nil, keeps existing positionInQueue.
    /// - Returns: A new ChatThread with the specified fields replaced.
    func copy(
        state: ChatThreadState? = nil,
        name: String? = nil,
        messages: [Message]? = nil,
        assignedAgent: Agent? = nil,
        lastAssignedAgent: Agent? = nil,
        ownerAssignee: Agent? = nil,
        contactId: String? = nil,
        scrollToken: String? = nil,
        positionInQueue: Int? = nil
    ) -> ChatThread {
        ChatThread(
            id: id,
            state: state ?? self.state,
            name: name ?? self.name,
            messages: messages ?? self.messages,
            assignedAgent: assignedAgent ?? self.assignedAgent,
            lastAssignedAgent: lastAssignedAgent ?? self.lastAssignedAgent,
            ownerAssignee: ownerAssignee ?? self.ownerAssignee,
            contactId: contactId ?? self.contactId,
            scrollToken: scrollToken ?? self.scrollToken,
            positionInQueue: positionInQueue ?? self.positionInQueue
        )
    }
}
