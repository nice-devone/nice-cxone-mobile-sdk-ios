import Foundation


/// Represents data of a thread recovered event.
struct ThreadRecoveredEventPostbackDTO: Codable {
    
    /// The type of the event.
    let eventType: EventType

    /// The data of the thread recovered event postback.
    let data: ThreadRecoveredEventPostbackDataDTO
}
