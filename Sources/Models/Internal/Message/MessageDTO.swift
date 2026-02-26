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

// MessageView

/// Represents all info about a message in a chat.
struct MessageDTO: Equatable {
    
    // MARK: - Properties
    
    /// The unique id for the message.
    @available(*, deprecated,
         renamed: "idOnExternalPlatformString",
         message: "Use `idOnExternalPlatformString`. It preserves the original case-sensitive identifier from the backend."
    )
    let idOnExternalPlatform: UUID // swiftlint:disable:this no_uuid
    
    /// The unique id for the message.
    let idOnExternalPlatformString: String
    
    /// The thread id for the message.
    @available(*, deprecated,
         renamed: "threadIdOnExternalPlatformString",
         message: "Use `threadIdOnExternalPlatformString`. It preserves the original case-sensitive identifier from the backend."
    )
    let threadIdOnExternalPlatform: UUID // swiftlint:disable:this no_uuid
    
    /// The thread id for the message.
    let threadIdOnExternalPlatformString: String
    
    /// The content of the message
    let contentType: MessageContentDTOType
    
    /// The timestamp of when the message was created.
    let createdAt: Date
    
    /// The attachments on the message.
    let attachments: [AttachmentDTO]
    
    /// The direction that the message is being sent (in regards to the agent).
    let direction: MessageDirectionDTOType
    
    /// An agent statistic information about the message (read status, viewed status, etc.).
    let agentStatistics: UserStatisticsDTO
    
    /// A user statistic information about the message (read status, viewed status, etc.).
    let customerStatistics: UserStatisticsDTO
    
    /// The agent that sent the message. Only present if the direction is outbound.
    let authorUser: AgentDTO?
    
    /// The customer that sent the message. Only present if the direction is inbound.
    let authorEndUserIdentity: CustomerIdentityDTO?
    
    // MARK: - Init
    
    init(
        idOnExternalPlatform: String,
        threadIdOnExternalPlatform: String,
        contentType: MessageContentDTOType,
        createdAt: Date,
        attachments: [AttachmentDTO],
        direction: MessageDirectionDTOType,
        agentStatistics: UserStatisticsDTO,
        customerStatistics: UserStatisticsDTO,
        authorUser: AgentDTO?,
        authorEndUserIdentity: CustomerIdentityDTO?
    ) {
        // swiftlint:disable:next no_uuid
        self.idOnExternalPlatform = UUID() // replaced with `idOnExternalPlatformString`
        self.idOnExternalPlatformString = idOnExternalPlatform
        // swiftlint:disable:next no_uuid
        self.threadIdOnExternalPlatform = UUID() // `threadIdOnExternalPlatformString`
        self.threadIdOnExternalPlatformString = threadIdOnExternalPlatform
        self.contentType = contentType
        self.createdAt = createdAt
        self.attachments = attachments
        self.direction = direction
        self.agentStatistics = agentStatistics
        self.customerStatistics = customerStatistics
        self.authorUser = authorUser
        self.authorEndUserIdentity = authorEndUserIdentity
    }
}

// MARK: - Decodable

extension MessageDTO: Decodable {
    
    enum CodingKeys: CodingKey {
        case idOnExternalPlatform
        case threadIdOnExternalPlatform
        case messageContent
        case createdAt
        case attachments
        case direction
        case userStatistics
        case customerStatistics
        case authorUser
        case authorEndUserIdentity
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        // swiftlint:disable:next no_uuid
        self.idOnExternalPlatform = try container.decode(UUID.self, forKey: .idOnExternalPlatform)
        self.idOnExternalPlatformString = try container.decode(String.self, forKey: .idOnExternalPlatform)
        // swiftlint:disable:next no_uuid
        self.threadIdOnExternalPlatform = try container.decode(UUID.self, forKey: .threadIdOnExternalPlatform)
        self.threadIdOnExternalPlatformString = try container.decode(String.self, forKey: .threadIdOnExternalPlatform)
        self.createdAt = try container.decodeISODate(forKey: .createdAt)
        self.attachments = try container.decode([AttachmentDTO].self, forKey: .attachments)
        self.direction = try container.decode(MessageDirectionDTOType.self, forKey: .direction)
        self.contentType = try container.decode(MessageContentDTOType.self, forKey: .messageContent)
        self.agentStatistics = try container.decodeIfPresent(UserStatisticsDTO.self, forKey: .userStatistics)
            ?? UserStatisticsDTO(seenAt: nil, readAt: nil)
        self.customerStatistics = try container.decodeIfPresent(UserStatisticsDTO.self, forKey: .customerStatistics)
            ?? UserStatisticsDTO(seenAt: nil, readAt: nil)
        self.authorUser = try container.decodeIfPresent(AgentDTO.self, forKey: .authorUser)
        self.authorEndUserIdentity = try container.decodeIfPresent(CustomerIdentityDTO.self, forKey: .authorEndUserIdentity)
    }
}
