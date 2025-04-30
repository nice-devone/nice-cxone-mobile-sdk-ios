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
    let idOnExternalPlatform: UUID
    
    /// The thread id for the message.
    let threadIdOnExternalPlatform: UUID
    
    /// The content of the message
    let contentType: MessageContentDTOType
    
    /// The timestamp of when the message was created.
    let createdAt: Date
    
    /// The attachments on the message.
    let attachments: [AttachmentDTO]
    
    /// The direction that the message is being sent (in regards to the agent).
    let direction: MessageDirectionDTOType
    
    /// Statistic information about the message (read status, viewed status, etc.).
    let userStatistics: UserStatisticsDTO
    
    /// The agent that sent the message. Only present if the direction is outbound.
    let authorUser: AgentDTO?
    
    /// The customer that sent the message. Only present if the direction is inbound.
    let authorEndUserIdentity: CustomerIdentityDTO?
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
        case authorUser
        case authorEndUserIdentity
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        self.idOnExternalPlatform = try container.decode(UUID.self, forKey: .idOnExternalPlatform)
        self.threadIdOnExternalPlatform = try container.decode(UUID.self, forKey: .threadIdOnExternalPlatform)
        self.createdAt = try container.decodeISODate(forKey: .createdAt)
        self.attachments = try container.decode([AttachmentDTO].self, forKey: .attachments)
        self.direction = try container.decode(MessageDirectionDTOType.self, forKey: .direction)
        self.contentType = try container.decode(MessageContentDTOType.self, forKey: .messageContent)
        self.userStatistics = try container.decode(UserStatisticsDTO.self, forKey: .userStatistics)
        self.authorUser = try container.decodeIfPresent(AgentDTO.self, forKey: .authorUser)
        self.authorEndUserIdentity = try container.decodeIfPresent(CustomerIdentityDTO.self, forKey: .authorEndUserIdentity)
    }
}
