import Foundation

/// Represents data of a thread recovered event.
struct ThreadRecoveredEventDTO: Decodable {
    
    /// The unique identifier of the event.
	let eventId: UUID

    /// The postback of the thread recovered event.
	let postback: ThreadRecoveredEventPostbackDTO
}
