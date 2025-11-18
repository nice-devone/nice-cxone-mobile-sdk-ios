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

/// Represents all info about a message in a chat.
public struct Message {
    
    // MARK: - Properties
    
    /// The unique id for the message.
    public let id: UUID
    
    /// The thread id for the message.
    public let threadId: UUID
    
    /// The content of the message
    public let contentType: MessageContentType
    
    /// The timestamp of when the message was created.
    public let createdAt: Date
    
    /// The attachments on the message.
    public let attachments: [Attachment]
    
    /// The direction that the message is being sent (in regards to the agent).
    public let direction: MessageDirection
    
    /// An agent statistic information about the message (read status, viewed status, etc.).
    @available(*, deprecated, renamed: "agentStatistics")
    public let userStatistics: UserStatistics?
    
    /// An agent statistic information about the message (read status, viewed status, etc.).
    public let agentStatistics: UserStatistics?
    
    /// A customer statistic information about the message (read status, viewed status, etc.).
    public let customerStatistics: UserStatistics?
    
    /// The agent that sent the message. Only present if the direction is to client (outbound).
    public let authorUser: Agent?
    
    /// The customer that sent the message. Only present if the direction is to agent (inbound).
    public let authorEndUserIdentity: CustomerIdentity?
    
    /// Information about the sender of a message.
    public var senderInfo: SenderInfo? {
        SenderInfo(message: self)
    }
    
    /// The delivery or read status of the message.
    public var status: MessageStatus
    
    // MARK: - Init
    
    /// Initializer of the Message object
    ///
    ///   - Note: The ``userStatistics`` attribute has been replaced with the ``agentStatistics`` so this initializer will be removed in a future release
    ///
    /// - Parameters:
    ///   - id: The unique id for the message.
    ///   - threadId: The thread id for the message.
    ///   - contentType: The content of the message
    ///   - createdAt: The timestamp of when the message was created.
    ///   - attachments: The attachments on the message.
    ///   - direction: The direction that the message is being sent (in regards to the agent).
    ///   - userStatistics: An agent statistic information about the message (read status, viewed status, etc.).
    ///   - agentStatistics: An agent statistic information about the message (read status, viewed status, etc.).
    ///   - customerStatistics: A customer statistic information about the message (read status, viewed status, etc.).
    ///   - authorUser: The agent that sent the message. Only present if the direction is to client (outbound).
    ///   - authorEndUserIdentity: The customer that sent the message. Only present if the direction is to agent (inbound).
    ///   - status: The delivery or read status of the message.
    @available(*, deprecated, message: "Due to replacement of the `userStatistics` atrribute with `agentStatistics` and new attribute `customerStatistics`, this initializer will be removed in a future.") // swiftlint:disable:this line_length
    public init(
        id: UUID,
        threadId: UUID,
        contentType: MessageContentType,
        createdAt: Date,
        attachments: [Attachment],
        direction: MessageDirection,
        userStatistics: UserStatistics?,
        authorUser: Agent?,
        authorEndUserIdentity: CustomerIdentity?,
        status: MessageStatus
    ) {
        self.id = id
        self.threadId = threadId
        self.contentType = contentType
        self.createdAt = createdAt
        self.attachments = attachments
        self.direction = direction
        self.userStatistics = userStatistics
        self.agentStatistics = userStatistics
        self.customerStatistics = nil
        self.authorUser = authorUser
        self.authorEndUserIdentity = authorEndUserIdentity
        self.status = status
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
    ///   - agentStatistics: An agent statistic information about the message (read status, viewed status, etc.).
    ///   - customerStatistics: A customer statistic information about the message (read status, viewed status, etc.).
    ///   - authorUser: The agent that sent the message. Only present if the direction is to client (outbound).
    ///   - authorEndUserIdentity: The customer that sent the message. Only present if the direction is to agent (inbound).
    ///   - status: The delivery or read status of the message.
    public init(
        id: UUID,
        threadId: UUID,
        contentType: MessageContentType,
        createdAt: Date,
        attachments: [Attachment],
        direction: MessageDirection,
        agentStatistics: UserStatistics?,
        customerStatistics: UserStatistics?,
        authorUser: Agent?,
        authorEndUserIdentity: CustomerIdentity?,
        status: MessageStatus
    ) {
        self.id = id
        self.threadId = threadId
        self.contentType = contentType
        self.createdAt = createdAt
        self.attachments = attachments
        self.direction = direction
        self.userStatistics = agentStatistics
        self.agentStatistics = agentStatistics
        self.customerStatistics = customerStatistics
        self.authorUser = authorUser
        self.authorEndUserIdentity = authorEndUserIdentity
        self.status = status
    }
}

// MARK: - Equatable

extension Message: Equatable {

    public static func == (lhs: Message, rhs: Message) -> Bool {
        lhs.id == rhs.id
            && lhs.threadId == rhs.threadId
            && lhs.contentType == rhs.contentType
            && lhs.createdAt == rhs.createdAt
            && lhs.attachments == rhs.attachments
            && lhs.direction == rhs.direction
            && lhs.userStatistics == rhs.agentStatistics
            && lhs.agentStatistics == rhs.agentStatistics
            && lhs.customerStatistics == rhs.customerStatistics
            && lhs.authorUser == rhs.authorUser
            && lhs.authorEndUserIdentity == rhs.authorEndUserIdentity
            && lhs.status == rhs.status
    }
}
