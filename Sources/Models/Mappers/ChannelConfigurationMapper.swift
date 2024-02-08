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

enum ChannelConfigurationMapper {
    
    static func map(_ entity: ChannelConfigurationDTO) -> ChannelConfiguration {
        ChannelConfiguration(
            hasMultipleThreadsPerEndUser: entity.settings.hasMultipleThreadsPerEndUser,
            isProactiveChatEnabled: entity.settings.isProactiveChatEnabled,
            isAuthorizationEnabled: entity.isAuthorizationEnabled,
            contactCustomFieldDefinitions: entity.contactCustomFieldDefinitions.map(CustomFieldTypeMapper.map),
            customerCustomFieldDefinitions: entity.customerCustomFieldDefinitions.map(CustomFieldTypeMapper.map)
        )
    }
    
    static func map(_ entity: ChannelConfiguration) -> ChannelConfigurationDTO {
        ChannelConfigurationDTO(
            settings: ChannelSettingsDTO(
                hasMultipleThreadsPerEndUser: entity.hasMultipleThreadsPerEndUser,
                isProactiveChatEnabled: entity.isProactiveChatEnabled
            ),
            isAuthorizationEnabled: entity.isAuthorizationEnabled,
            prechatSurvey: nil,
            contactCustomFieldDefinitions: entity.contactCustomFieldDefinitions.map(CustomFieldTypeMapper.map),
            customerCustomFieldDefinitions: entity.customerCustomFieldDefinitions.map(CustomFieldTypeMapper.map)
        )
    }
}
