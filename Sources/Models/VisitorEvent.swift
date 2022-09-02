import Foundation

// Visitor Event

/// Represents all info about a visitor event to be sent.
struct VisitorEvent: Encodable {
    
    /// The unique id of the event.
    public let id: LowerCaseUUID
    
    /// The type of visitor event.
    public let type: VisitorEventType

    /// The timestamp of when the visitor event was created (with additional milliseconds).
    public let createdAtWithMilliseconds: String
    
    /// Data about the visitor event.
    public let data: VisitorEventData?
}
