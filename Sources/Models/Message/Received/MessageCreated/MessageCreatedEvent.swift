import Foundation

// MessageCreated

/// Event Received when a message has been successfully sent/created.
public struct MessageCreatedEvent: ReceivedEvent, Codable {
    public var eventId: UUID
    
    public var eventObject: EventObject
    
    public var eventType: EventType
    
    public var createdAt: String // TODO: Change type to Date
    
	public var data: MessageCreatedEventData
}
