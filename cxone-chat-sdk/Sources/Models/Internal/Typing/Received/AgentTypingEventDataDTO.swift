import Foundation

/// The data for the AgentTypingEvent.
struct AgentTypingEventDataDTO: Codable {

    let brand: BrandDTO

    let channel: ChannelIdentifierDTO

    let thread: ThreadDTO

    let user: AgentDTO?
}
