import Foundation

/// Generic structure that applies to all received events.
public protocol ReceivedEvent: Codable {
    
    /// The unique id of the event.
    var eventId: UUID { get }
    
    /// The type of object for which this event applies.
    var eventObject: EventObject { get }
    
    /// The type of event received.
    var eventType: EventType { get }
    
    /// The time at which this event was created.
    var createdAt: String { get } // TODO: Change type to Date

}
