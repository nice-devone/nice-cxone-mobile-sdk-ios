import Foundation


/// Represents information about a customer identity to be sent on events.
public struct CustomerIdentity {
    
    // MARK: - Properties
    
    /// The unique id for the customer identity.
    public let id: String
    
    /// The first name of the customer. Use when sending a message to set the name in MAX.
    public var firstName: String?
    
    /// The last name of the customer. Use when sending a message to set the name in MAX.
    public var lastName: String?
    
    /// The full name of the customer.
    public var fullName: String? {
        "\(firstName ?? "") \(lastName ?? "")"
    }
    
    
    // MARK: - Init
    
    /// - Parameters:
    ///   - id: The unique id for the customer identity.
    ///   - firstName: The first name of the customer. Use when sending a message to set the name in MAX.
    ///   - lastName: The last name of the customer. Use when sending a message to set the name in MAX.
    public init(id: String, firstName: String?, lastName: String?) {
        self.id = id
        self.firstName = firstName
        self.lastName = lastName
    }
}
