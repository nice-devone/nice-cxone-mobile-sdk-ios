import Foundation

/// Event received when more messages are loaded.
struct MoreMessagesLoadedEventDTO: Decodable {
    
    /// The unique identifier of the event.
    let eventId: UUID

    /// The postback of the more message loaded event.
    let postback: MoreMessagesLoadedEventPostbackDTO
}
