import Foundation

// CaseInboxAssigneeChanged

/// Event response that the assigned agent for the contact has changed.
struct ContactInboxAssigneeChangedEvent: ReceivedEvent, Codable {
    
	var eventId: UUID
    
	var eventObject: EventObject
    
    var eventType: EventType
    
	var createdAt: String // TODO: Change type to Date
    
    /// The data about the changed assignee.
	var data: ContactInboxAssigneeChangedData
}
