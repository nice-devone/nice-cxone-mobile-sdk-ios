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
