/// Settings on a channel.
public struct ChannelSettings: Codable {
    /// Whether the channel supports multiple threads for the same user.
    public let hasMultipleThreadsPerEndUser: Bool
    
    // Whether the channel supports proactive chat features.
    public let isProactiveChatEnabled: Bool
}
