import Foundation


/// Represents all data about a single custom field.
struct CustomFieldDTO: Codable {

    // MARK: - Properties

    let ident: String

    var value: String
    
    var updatedAt: Date


    // MARK: - Init

    /// - Parameters:
    ///   - ident: The key of the custom field data.
    ///   - value: The actual value of the custom field.
    ///   - updatedAt: The timestamp of the value when the value has been created/updated.
    init(ident: String, value: String, updatedAt: Date) {
        self.ident = ident
        self.value = value
        self.updatedAt = updatedAt
    }
    
    
    // MARK: - Codable
    
    enum CodingKeys: CodingKey {
        case ident
        case value
        case updatedAt
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        self.ident = try container.decode(String.self, forKey: .ident)
        self.value = try container.decode(String.self, forKey: .value)
        self.updatedAt = try container.decodeISODate(forKey: .updatedAt)
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        
        try container.encode(ident, forKey: .ident)
        try container.encode(value, forKey: .value)
        try container.encodeISODate(updatedAt, forKey: .updatedAt)
    }
}
