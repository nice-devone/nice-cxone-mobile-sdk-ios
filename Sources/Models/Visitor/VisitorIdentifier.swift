import Foundation

/// Limited scope of info about a visitor to be sent on events.
internal struct VisitorIdentifier: Codable {
    
    /// The id of the visitor.
    let id: LowerCaseUUID
}
