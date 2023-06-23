import Foundation


/// Settings on a channel.
struct ChannelSettingsDTO: Decodable {
    
    /// Whether the channel supports multiple threads for the same user.
    let hasMultipleThreadsPerEndUser: Bool

    /// Whether the channel supports proactive chat features.
    let isProactiveChatEnabled: Bool
}
