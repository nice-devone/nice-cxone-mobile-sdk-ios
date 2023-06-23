import Foundation


// CaseInboxAssigneeChanged

/// Event response that the assigned agent for the contact has changed.
struct ContactInboxAssigneeChangedEventDTO: ReceivedEvent {
    
    // MARK: - Properties
    
    let eventId: UUID
    
    let eventObject: EventObjectType
    
    let eventType: EventType
    
    let createdAt: Date
    
    /// The data about the changed assignee.
    let data: ContactInboxAssigneeChangedDataDTO
    
    
    // MARK: - Init
    
    init(eventId: UUID, eventObject: EventObjectType, eventType: EventType, createdAt: Date, data: ContactInboxAssigneeChangedDataDTO) {
        self.eventId = eventId
        self.eventObject = eventObject
        self.eventType = eventType
        self.createdAt = createdAt
        self.data = data
    }
}


// MARK: - Decodable

extension ContactInboxAssigneeChangedEventDTO: Decodable {
    
    enum CodingKeys: CodingKey {
        case eventId
        case eventObject
        case eventType
        case createdAt
        case data
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        self.eventId = try container.decode(UUID.self, forKey: .eventId)
        self.eventObject = try container.decode(EventObjectType.self, forKey: .eventObject)
        self.eventType = try container.decode(EventType.self, forKey: .eventType)
        self.createdAt = try container.decodeISODate(forKey: .createdAt)
        self.data = try container.decode(ContactInboxAssigneeChangedDataDTO.self, forKey: .data)
    }
}
