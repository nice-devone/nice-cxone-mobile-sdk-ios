import CXoneChatSDK

class GetChannelConfigurationUseCase {
    
    func callAsFunction(configuration: Configuration) async throws -> ChannelConfiguration {
        if let environment = configuration.environment {
            return try await CXoneChat.shared.connection.getChannelConfiguration(
                environment: environment,
                brandId: configuration.brandId,
                channelId: configuration.channelId
            )
        } else {
            return try await CXoneChat.shared.connection.getChannelConfiguration(
                chatURL: configuration.chatUrl,
                brandId: configuration.brandId,
                channelId: configuration.channelId
            )
        }
    }
}
