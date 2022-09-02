import Foundation

/// The data for the AgentTypingEvent.
struct AgentTypingEventData: Codable {
    var brand: Brand
    var channel: ChannelIdentifier
    var thread: Thread
    var user: Agent?
}
