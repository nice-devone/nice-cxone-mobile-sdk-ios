import Foundation


// Visitor Event

/// Represents all info about a visitor event to be sent.
struct VisitorEventDTO: Encodable {
    
    /// The unique id of the event.
    let id: LowerCaseUUID
    
    /// The type of visitor event.
    let type: VisitorEventType

    /// The timestamp of when the visitor event was created (with additional milliseconds).
    let createdAtWithMilliseconds: String
    
    /// Data about the visitor event.
    let data: VisitorEventDataType?
}
