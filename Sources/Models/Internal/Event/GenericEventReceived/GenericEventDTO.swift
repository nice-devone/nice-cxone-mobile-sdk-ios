import Foundation


/// The initial decoding of a message from the WebSocket.
struct GenericEventDTO: Codable {
    
    /// The type of the event.
	let eventType: EventType?

    /// The postback of the event.
	let postback: GenericEventPostbackDTO?

    let error: OperationError?

    let internalServerError: InternalServerError?
}
