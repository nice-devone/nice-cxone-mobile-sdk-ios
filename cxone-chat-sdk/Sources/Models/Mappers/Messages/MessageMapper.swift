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

enum MessageMapper {
    
    static func map(_ entity: Message) throws -> MessageDTO {
        MessageDTO(
            idOnExternalPlatform: entity.id,
            threadIdOnExternalPlatform: entity.threadId,
            contentType: try MessageContentTypeMapper.map(entity.contentType),
            createdAt: entity.createdAt,
            attachments: entity.attachments.map(AttachmentMapper.map),
            direction: Self.map(entity.direction),
            userStatistics: UserStatisticsDTO(seenAt: entity.userStatistics?.seenAt, readAt: entity.userStatistics?.readAt),
            authorUser: entity.authorUser.map(AgentMapper.map),
            authorEndUserIdentity: entity.authorEndUserIdentity.map(CustomerIdentityMapper.map)
        )
    }
    
    static func map(_ entity: MessageDTO) -> Message {
        Message(
            id: entity.idOnExternalPlatform,
            threadId: entity.threadIdOnExternalPlatform,
            contentType: MessageContentTypeMapper.map(entity.contentType),
            createdAt: entity.createdAt,
            attachments: entity.attachments.map(AttachmentMapper.map),
            direction: Self.map(entity.direction),
            userStatistics: UserStatistics(seenAt: entity.userStatistics.seenAt, readAt: entity.userStatistics.readAt),
            authorUser: entity.authorUser.map(AgentMapper.map),
            authorEndUserIdentity: entity.authorEndUserIdentity.map(CustomerIdentityMapper.map)
        )
    }
}

// MARK: - MessageDirection mapper

private extension MessageMapper {
    
    static func map(_ direction: MessageDirectionDTOType) -> MessageDirection {
        switch direction {
        case .inbound:
            return .toAgent
        case .outbound:
            return .toClient
        }
    }
    
    static func map(_ direction: MessageDirection) -> MessageDirectionDTOType {
        switch direction {
        case .toAgent:
            return .inbound
        case .toClient:
            return .outbound
        }
    }
}
