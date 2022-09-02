import Foundation

// SenderTypingStarted

/// Event received when the agent begins typing or stops typing.
struct AgentTypingEvent: ReceivedEvent, Codable {
	var eventId: UUID
	var eventObject: EventObject
    var eventType: EventType
	var createdAt: String // TODO: Change type to Date
	var data: AgentTypingEventData
}

