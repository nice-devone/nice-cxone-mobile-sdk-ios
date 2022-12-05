import Foundation


// CustomerIdentityView

/// Represents information about a customer identity to be sent on events.
struct CustomerIdentityDTO: Codable {
    
    /// The unique id for the customer identity.
    let idOnExternalPlatform: String
    
    /// The first name of the customer. Use when sending a message to set the name in MAX.
    var firstName: String?
    
    /// The last name of the customer. Use when sending a message to set the name in MAX.
    var lastName: String?
}
