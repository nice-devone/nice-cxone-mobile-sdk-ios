import Foundation

/// Event received when an agent has read a message.
public struct MessageReadByAgentEvent: Codable {
	public var eventId: UUID
	public var eventObject: EventObject
	public var eventType: EventType
	public var createdAt: String // TODO: Change type to Date
	public var data: MessageReadByAgentEventData
}

