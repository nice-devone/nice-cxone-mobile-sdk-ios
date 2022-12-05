import Foundation


struct SetContactCustomFieldsEventDataDTO: Codable {
    
    // MARK: - Properties
    
    let thread: ThreadDTO

    let customFields: [CustomFieldDTO]

    let contactId: String
    
    
    // MARK: - Init
    
    init(thread: ThreadDTO, customFields: [CustomFieldDTO], contactId: String) {
        self.thread = thread
        self.customFields = customFields
        self.contactId = contactId
    }
    
    
    // MARK: - Codable
    
    enum CodingKeys: CodingKey {
        case thread
        case customFields
        case consumerContact
    }
    
    enum ConsumerContactKeys: CodingKey {
        case id
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let contactIdentifierContainer = try container.nestedContainer(keyedBy: ConsumerContactKeys.self, forKey: .consumerContact)
        
        self.thread = try container.decode(ThreadDTO.self, forKey: .thread)
        self.customFields = try container.decode([CustomFieldDTO].self, forKey: .customFields)
        self.contactId = try contactIdentifierContainer.decode(String.self, forKey: .id)
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        var contactIdentifierContainer = container.nestedContainer(keyedBy: ConsumerContactKeys.self, forKey: .consumerContact)
        
        try container.encode(thread, forKey: .thread)
        try container.encode(customFields, forKey: .customFields)
        try contactIdentifierContainer.encode(contactId, forKey: .id)
    }
}
