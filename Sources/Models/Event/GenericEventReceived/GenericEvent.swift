import Foundation

/// The initial decoding of a message from the WebSocket.
public struct GenericEvent: Codable {
	public var eventType: EventType?
	public var postback: GenericEventPostback?
    let error: OperationError?
}
