import Foundation


/// The various options for how a channel is configured.
public struct ChannelConfiguration: Codable {
    
    /// Whether the channel supports multiple threads for the same user.
    public let hasMultipleThreadsPerEndUser: Bool

    /// Whether the channel supports proactive chat features.
    public let isProactiveChatEnabled: Bool

    /// Whether OAuth authorization is enabled for the channel.
    public let isAuthorizationEnabled: Bool
}
