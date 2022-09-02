import Foundation

/// The list of all statuses on a contact.
public enum ContactStatus: String, Codable {
    /// The contact is newly opened.
    case new
    
    /// The contact is currently open.
    case open

    /// The contact is pending.
    case pending

    /// The contact has been escalated.
    case escalated

    /// The contact has been resolved.
    case resolved

    /// The contact is closed.
    case closed
    
    /// The contact contains some unknown status string.
    case unknown
    
    /// Allows for decoding with an unknown string.
    public init(from decoder: Decoder) throws {
        self = try ContactStatus(rawValue: decoder.singleValueContainer().decode(RawValue.self)) ?? .unknown
    }
}
