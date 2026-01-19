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

/// Represents all info about a message in a chat.
public struct Message {
    
    // MARK: - Properties
    
    /// The unique id for the message. Refers to the `idOnExternalPlatform`.
    @available(*, deprecated, renamed: "idString", message: "Use `idString`. It preserves the original case-sensitive identifier from the backend.")
    public let id: UUID
    
    /// The unique id for the message. Refers to the `idOnExternalPlatform`.
    ///
    /// The canonical, case-preserving identifier of the message as provided by the backend.
    /// Stores the **exact** value from the backend (e.g., a UUID string), without altering case.
    public let idString: String
    
    /// The thread id for the message. Refers to the `threadIdOnExternalPlatform`.
    @available(*, deprecated, renamed: "threadIdString", message: "Use `threadIdString`. It preserves the original case-sensitive identifier from the backend.")
    public let threadId: UUID
    
    /// The thread id for the message. Refers to the `threadIdOnExternalPlatform`.
    ///
    /// The canonical, case-preserving identifier of the thread as provided by the backend.
    /// Stores the **exact** value from the backend (e.g., a UUID string), without altering case.
    public let threadIdString: String
    
    /// The content of the message
    public let contentType: MessageContentType
    
    /// The timestamp of when the message was created.
    public let createdAt: Date
    
    /// The attachments on the message.
    public let attachments: [Attachment]
    
    /// The direction that the message is being sent (in regards to the agent).
    public let direction: MessageDirection
    
    /// Statistic information about the message (read status, viewed status, etc.).
    public let userStatistics: UserStatistics?
    
    /// The agent that sent the message. Only present if the direction is to client (outbound).
    public let authorUser: Agent?
    
    /// The customer that sent the message. Only present if the direction is to agent (inbound).
    public let authorEndUserIdentity: CustomerIdentity?
    
    /// Information about the sender of a message.
    public var senderInfo: SenderInfo {
        SenderInfo(message: self)
    }
    
    /// The delivery or read status of the message.
    public var status: MessageStatus {
        switch userStatistics {
        case .some(let statistics) where statistics.readAt != nil:
            return .seen
        case .some:
            return .delivered
        case .none:
            return .sent
        }
    }
    
    // MARK: - Init
    
    /// - Parameters:
    ///   - id: The unique id for the message.
    ///   - threadId: The thread id for the message.
    ///   - messageContent: The content of the message
    ///   - createdAt: The timestamp of when the message was created.
    ///   - attachments: The attachments on the message.
    ///   - direction: The direction that the message is being sent (in regards to the agent).
    ///   - userStatistics: Statistic information about the message (read status, viewed status, etc.).
    ///   - authorUser: The agent that sent the message. Only present if the direction is to client (outbound).
    ///   - authorEndUserIdentity: The customer that sent the message. Only present if the direction is to agent (inbound).
    @available(
        *, deprecated,
         message: "Use alternative with `String` parameter for `id` and `threadId`. It preserves the original case-sensitive identifier from the backend."
    )
    public init(
        id: UUID,
        threadId: UUID,
        contentType: MessageContentType,
        createdAt: Date,
        attachments: [Attachment],
        direction: MessageDirection,
        userStatistics: UserStatistics?,
        authorUser: Agent?,
        authorEndUserIdentity: CustomerIdentity?
    ) {
        self.id = id
        self.idString = id.uuidString.lowercased()
        self.threadId = threadId
        self.threadIdString = threadId.uuidString.lowercased()
        self.contentType = contentType
        self.createdAt = createdAt
        self.attachments = attachments
        self.direction = direction
        self.userStatistics = userStatistics
        self.authorUser = authorUser
        self.authorEndUserIdentity = authorEndUserIdentity
    }
    
    /// Initializer of the Message object
    ///
    /// - Parameters:
    ///   - id: The unique id for the message.
    ///   - threadId: The thread id for the message.
    ///   - contentType: The content of the message
    ///   - createdAt: The timestamp of when the message was created.
    ///   - attachments: The attachments on the message.
    ///   - direction: The direction that the message is being sent (in regards to the agent).
    ///   - customerStatistics: A customer statistic information about the message (read status, viewed status, etc.).
    ///   - authorUser: The agent that sent the message. Only present if the direction is to client (outbound).
    ///   - authorEndUserIdentity: The customer that sent the message. Only present if the direction is to agent (inbound).
    init(
        id: String,
        threadId: String,
        contentType: MessageContentType,
        createdAt: Date,
        attachments: [Attachment],
        direction: MessageDirection,
        userStatistics: UserStatistics?,
        authorUser: Agent?,
        authorEndUserIdentity: CustomerIdentity?
    ) {
        self.id = UUID() // `id` has been replaced with `idString` and since it's under the internal init we don't want to use it anymore
        self.idString = id
        self.threadId = UUID() // `threadId` has been replaced with `threadIdString` and since it's under the internal init we don't want to use it anymore
        self.threadIdString = threadId
        self.contentType = contentType
        self.createdAt = createdAt
        self.attachments = attachments
        self.direction = direction
        self.userStatistics = userStatistics
        self.authorUser = authorUser
        self.authorEndUserIdentity = authorEndUserIdentity
    }
}

// MARK: - Equatable

extension Message: Equatable {

    public static func == (lhs: Message, rhs: Message) -> Bool {
        lhs.idString == rhs.idString
    }
}
