import Foundation

/// The various options for how a channel is configured.
public struct ChannelConfiguration: Codable {
    
    /// Settings for the channel.
    public let settings: ChannelSettings
    
    /// Whether OAuth authorization is enabled for the channel.
    public let isAuthorizationEnabled: Bool
}
