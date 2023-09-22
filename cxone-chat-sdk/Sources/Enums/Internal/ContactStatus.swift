import Foundation

/// The list of all statuses on a contact.
enum ContactStatus: String {
    
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
}

// MARK: - Codable

extension ContactStatus: Codable {
    
    init(from decoder: Decoder) throws {
        self = try ContactStatus(rawValue: decoder.singleValueContainer().decode(RawValue.self)) ?? .unknown
    }
}
