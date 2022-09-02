import Foundation

/// Represents all data about a single custom field.
public struct CustomField: Codable {
    public var ident: String
    public var value: String
    
    public init(ident: String, value: String) {
        self.ident = ident
        self.value = value
    }
}
