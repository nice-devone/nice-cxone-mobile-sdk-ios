import Foundation

// ContactView

/// Represents all info about a contact (case).
public struct Contact: Codable {
        
    /// The id of the contact.
    public var id: String

    /// The id of the thread for which this contact applies.
    public var threadIdOnExternalPlatform: UUID
    
    public var status: ContactStatus

    public var createdAt: String // TODO: Change type to Date
}
