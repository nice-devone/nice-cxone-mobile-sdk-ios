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

enum MessageMapper {
    
    static func map(_ entity: MessageDTO) -> Message? {
        guard let contentType = MessageContentTypeMapper.map(entity.contentType) else {
            return nil
        }
        
        return Message(
            id: entity.idOnExternalPlatform,
            threadId: entity.threadIdOnExternalPlatform,
            contentType: contentType,
            createdAt: entity.createdAt,
            attachments: entity.attachments.map(AttachmentMapper.map),
            direction: entity.direction == .inbound ? .toAgent : .toClient,
            agentStatistics: UserStatistics(
                seenAt: entity.agentStatistics.seenAt,
                readAt: entity.agentStatistics.readAt
            ),
            customerStatistics: UserStatistics(
                seenAt: entity.customerStatistics.seenAt,
                readAt: entity.customerStatistics.readAt
            ),
            authorUser: entity.authorUser.map(AgentMapper.map),
            authorEndUserIdentity: entity.authorEndUserIdentity.map(CustomerIdentityMapper.map),
            status: entity.agentStatistics.readAt != nil ? .seen : .delivered
        )
    }
    
    static func map(from entity: SendMessageEventDataDTO, payload: MessagePayload, authorUser: Agent?, customer: CustomerIdentity?) -> Message {
        Message(
            id: entity.idOnExternalPlatform,
            threadId: entity.thread.idOnExternalPlatform,
            contentType: .text(payload),
            createdAt: Date(),
            attachments: entity.attachments.map(AttachmentMapper.map),
            direction: .toAgent,
            agentStatistics: nil,
            customerStatistics: nil,
            authorUser: authorUser,
            authorEndUserIdentity: customer,
            status: .sent
        )
    }
}
