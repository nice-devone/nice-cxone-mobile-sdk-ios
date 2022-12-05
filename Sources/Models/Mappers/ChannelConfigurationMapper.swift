import Foundation


enum ChannelConfigurationMapper {
    
    static func map(_ entity: ChannelConfigurationDTO) -> ChannelConfiguration {
        .init(
            hasMultipleThreadsPerEndUser: entity.settings.hasMultipleThreadsPerEndUser,
            isProactiveChatEnabled: entity.settings.isProactiveChatEnabled,
            isAuthorizationEnabled: entity.isAuthorizationEnabled
        )
    }
    
    static func map(_ entity: ChannelConfiguration) -> ChannelConfigurationDTO {
        .init(
            settings: .init(
                hasMultipleThreadsPerEndUser: entity.hasMultipleThreadsPerEndUser,
                isProactiveChatEnabled: entity.isProactiveChatEnabled
            ),
            isAuthorizationEnabled: entity.isAuthorizationEnabled
        )
    }
}
