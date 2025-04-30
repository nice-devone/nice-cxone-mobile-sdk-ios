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

import XCTest
@testable import CXoneChatSDK

extension MessageMapper {
    
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
    
    // MARK: - Private methods
    
    private static func map(_ direction: MessageDirection) -> MessageDirectionDTOType {
        switch direction {
        case .toAgent:
            return .inbound
        case .toClient:
            return .outbound
        }
    }
}

// MARK: - Helpers

private extension MessageContentTypeMapper {
    
    static func map(_ entity: MessageContentType) throws -> MessageContentDTOType {
        switch entity {
        case .text(let entity):
            return .text(MessagePayloadMapper.map(entity))
        case .richLink(let entity):
            return .richLink(MessageRichLinkMapper.map(from: entity))
        case .quickReplies(let entity):
            return .quickReplies(MessageQuickRepliesMapper.map(from: entity))
        case .listPicker(let entity):
            return .listPicker(MessageListPickerMapper.map(from: entity))
        case .unknown:
            return .unknown
        }
    }
}

private extension MessagePayloadMapper {
    
    static func map(_ entity: MessagePayload) -> MessagePayloadDTO {
        MessagePayloadDTO(text: entity.text, postback: entity.postback)
    }
}

private extension MessageRichLinkMapper {
    
    static func map(from entity: MessageRichLink) -> MessageRichLinkDTO {
        MessageRichLinkDTO(title: entity.title, url: entity.url, fileName: entity.fileName, fileUrl: entity.fileUrl, mimeType: entity.mimeType)
    }
}

private extension MessageQuickRepliesMapper {
    
    static func map(from entity: MessageQuickReplies) -> MessageQuickRepliesDTO {
        MessageQuickRepliesDTO(title: entity.title, buttons: entity.buttons.map(MessageReplyButtonMapper.map))
    }
}

private extension MessageReplyButtonMapper {
    
    static func map(from entity: MessageReplyButton) -> MessageReplyButtonDTO {
        MessageReplyButtonDTO(
            text: entity.text,
            postback: entity.postback,
            description: entity.description,
            iconName: entity.iconName,
            iconUrl: entity.iconUrl,
            iconMimeType: entity.iconMimeType
        )
    }
}

private extension MessageListPickerMapper {
    
    static func map(from entity: MessageListPicker) -> MessageListPickerDTO {
        MessageListPickerDTO(title: entity.title, text: entity.text, buttons: entity.buttons.map(MessageSubElementMapper.map))
    }
}

private extension MessageSubElementMapper {
    
    static func map(from type: MessageSubElementType) -> MessageSubElementDTOType {
        switch type {
        case .replyButton(let entity):
            return .replyButton(MessageReplyButtonMapper.map(from: entity))
        }
    }
}

private extension AttachmentMapper {
    
    static func map(_ entity: Attachment) -> AttachmentDTO {
        AttachmentDTO(url: entity.url, friendlyName: entity.friendlyName, mimeType: entity.mimeType, fileName: entity.fileName)
    }
}

private extension AgentMapper {
    
    static func map(_ entity: Agent) -> AgentDTO {
        AgentDTO(
            id: entity.id,
            firstName: entity.firstName,
            surname: entity.surname,
            nickname: entity.nickname,
            isBotUser: entity.isBotUser,
            isSurveyUser: entity.isSurveyUser,
            publicImageUrl: entity.imageUrl
        )
    }
}
