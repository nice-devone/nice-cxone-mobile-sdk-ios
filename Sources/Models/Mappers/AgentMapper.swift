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

enum AgentMapper {
    
    static func map(_ entity: Agent) -> AgentDTO {
        AgentDTO(
            id: entity.id,
            inContactId: entity.inContactId,
            emailAddress: entity.emailAddress,
            loginUsername: entity.loginUsername,
            firstName: entity.firstName,
            surname: entity.surname,
            nickname: entity.nickname,
            isBotUser: entity.isBotUser,
            isSurveyUser: entity.isSurveyUser,
            imageUrl: entity.imageUrl
        )
    }
    
    static func map(_ entity: AgentDTO) -> Agent {
        Agent(
            id: entity.id,
            inContactId: entity.inContactId,
            emailAddress: entity.emailAddress,
            loginUsername: entity.loginUsername,
            firstName: entity.firstName,
            surname: entity.surname,
            nickname: entity.nickname,
            isBotUser: entity.isBotUser,
            isSurveyUser: entity.isSurveyUser,
            imageUrl: entity.imageUrl
        )
    }
}
