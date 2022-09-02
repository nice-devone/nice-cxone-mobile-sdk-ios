import Foundation

// CustomerIdentityView

/// Represents information about a customer identity to be sent on events.
public struct CustomerIdentity: Codable {

    /// The unique id for the customer identity.
    let idOnExternalPlatform: String
    
    /// The first name of the customer. Use when sending a message to set the name in MAX.
    var firstName: String? = nil
    
    /// The last name of the customer. Use when sending a message to set the name in MAX.
    var lastName: String? = nil
    
    /// The full name of the customer.
    var fullName: String? {
        return "\(firstName ?? "") \(lastName ?? "")"
    }
}
