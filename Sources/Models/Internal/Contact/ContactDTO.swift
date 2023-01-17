import Foundation


// ContactView

/// Represents all info about a contact (case).
struct ContactDTO: Codable {

    // MARK: - Properties

    /// The id of the contact.
    let id: String

    /// The id of the thread for which this contact applies.
    let threadIdOnExternalPlatform: UUID

    /// The status of the contact.
    let status: ContactStatus

    /// The timestamp of when the message was created.
    let createdAt: Date
    
    let customFields: [CustomFieldDTO]
    
    
    // MARK: - Init
    
    init(id: String, threadIdOnExternalPlatform: UUID, status: ContactStatus, createdAt: Date, customFields: [CustomFieldDTO]) {
        self.id = id
        self.threadIdOnExternalPlatform = threadIdOnExternalPlatform
        self.status = status
        self.createdAt = createdAt
        self.customFields = customFields
    }
    
    
    // MARK: - Codable
    
    /// The Contact coding keys.
    enum CodingKeys: CodingKey {
        /// The id of the contact.
        case id
        /// The id of the thread for which this contact applies.
        case threadIdOnExternalPlatform
        /// The status of the contact.
        case status
        /// The timestamp of when the message was created.
        case createdAt
        case customFields
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        self.id = try container.decode(String.self, forKey: .id)
        self.threadIdOnExternalPlatform = try container.decode(UUID.self, forKey: .threadIdOnExternalPlatform)
        self.status = try container.decode(ContactStatus.self, forKey: .status)
        self.createdAt = try container.decodeISODate(forKey: .createdAt)
        self.customFields = try container.decode([CustomFieldDTO].self, forKey: .customFields)
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        
        try container.encode(id, forKey: .id)
        try container.encode(threadIdOnExternalPlatform, forKey: .threadIdOnExternalPlatform)
        try container.encode(status, forKey: .status)
        try container.encodeISODate(createdAt, forKey: .createdAt)
        try container.encode(customFields, forKey: .customFields)
    }
}
