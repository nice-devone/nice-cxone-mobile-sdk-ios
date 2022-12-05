import Foundation


/// The various options for how a channel is configured.
struct ChannelConfigurationDTO: Codable {
    
    /// Settings for the channel.
    let settings: ChannelSettingsDTO

    /// Whether OAuth authorization is enabled for the channel.
    let isAuthorizationEnabled: Bool
}
