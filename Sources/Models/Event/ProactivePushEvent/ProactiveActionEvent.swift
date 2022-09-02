

import Foundation

internal struct ProactiveActionEvent: ReceivedEvent, Codable {
    public var eventId: UUID
    
    public var eventObject: EventObject
    
    public var eventType: EventType
    
    public var createdAt: String // TODO: Change type to Date
    
    public var data:  ProactiveActionEventData
}
