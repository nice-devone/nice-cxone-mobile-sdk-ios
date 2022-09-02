import Foundation

/// Event received when more messages are loaded.
struct MoreMessagesLoadedEvent: Codable {
    let eventId: UUID
    let postback: MoreMessagesLoadedEventPostback
}
