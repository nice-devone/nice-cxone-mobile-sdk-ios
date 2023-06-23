import Foundation


/// Event received when a customer is successfully authorized.
struct CustomerAuthorizedEventDTO: Decodable {
    
    /// The unique identifier of the event.
    let eventId: UUID

    /// The postback for the customer authorized event.
    let postback: CustomerAuthorizedEventPostbackDTO
}
