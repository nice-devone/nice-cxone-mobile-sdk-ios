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

enum ChatThreadMapper {
    
    static func map(_ entity: ChatThread) throws -> ChatThreadDTO {
        ChatThreadDTO(
            idOnExternalPlatform: entity.id,
            threadName: entity.name,
            messages: try entity.messages.map(MessageMapper.map),
            threadAgent: entity.assignedAgent.map(AgentMapper.map),
            canAddMoreMessages: entity.canAddMoreMessages,
            contactId: entity.contactId,
            scrollToken: entity.scrollToken
        )
    }
    
    static func map(_ entity: ChatThreadDTO) -> ChatThread {
        ChatThread(
            id: entity.idOnExternalPlatform,
            name: entity.threadName,
            messages: entity.messages.map(MessageMapper.map),
            assignedAgent: entity.threadAgent.map(AgentMapper.map),
            canAddMoreMessages: entity.canAddMoreMessages,
            contactId: entity.contactId,
            scrollToken: entity.scrollToken
        )
    }
}
