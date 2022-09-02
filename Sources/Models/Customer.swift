import Foundation

// CustomerView

/// Represents all info about a customer.
public struct Customer: Codable {
    public var id: String
    
    /// The first name of the customer.
    public var firstName: String
    
    /// The last name of the customer.
    public var lastName: String
    
    /// The full name of the user.
    public var fullName: String {
        return "\(firstName) \(lastName)"
    }
    
    public init(id: String, firstName: String, lastName: String) {
        self.id = id
        self.firstName = firstName
        self.lastName = lastName
    }
}
