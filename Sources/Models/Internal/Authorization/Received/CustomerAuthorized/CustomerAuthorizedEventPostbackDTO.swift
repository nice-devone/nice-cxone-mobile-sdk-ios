import Foundation


/// Represents info about a postback for a customer authorized event.
struct CustomerAuthorizedEventPostbackDTO: Decodable {
    
    /// The type of the event.
    let eventType: EventType

    /// The data of the customer authorized postback event.
    let data: CustomerAuthorizedEventPostbackDataDTO
}
