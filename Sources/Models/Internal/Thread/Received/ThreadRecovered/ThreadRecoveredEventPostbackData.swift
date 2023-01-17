import Foundation


/// Represents data about a thread recovered event postback.
struct ThreadRecoveredEventPostbackDataDTO: Codable {
    
    // MARK: - Properties
    
    /// The info about a contact (case).
    let consumerContact: ContactDTO

    /// The list of messages on the thread.
    let messages: [MessageDTO]

    /// The info about an agent.
    let inboxAssignee: AgentDTO?

    /// The info abount about received thread.
    let thread: ReceivedThreadDataDTO

    /// The scroll token of the messages.
    let messagesScrollToken: String
    
    let customerContactFields: [CustomFieldDTO]
    
    
    // MARK: - Init
    
    init(
        consumerContact: ContactDTO,
        messages: [MessageDTO],
        inboxAssignee: AgentDTO?,
        thread: ReceivedThreadDataDTO,
        messagesScrollToken: String,
        customerContactFields: [CustomFieldDTO]
    ) {
        self.consumerContact = consumerContact
        self.messages = messages
        self.inboxAssignee = inboxAssignee
        self.thread = thread
        self.messagesScrollToken = messagesScrollToken
        self.customerContactFields = customerContactFields
    }
    
    
    // MARK: - Codable
    
    enum CodingKeys: CodingKey {
        case consumerContact
        case messages
        case inboxAssignee
        case thread
        case messagesScrollToken
        case customer
    }
    
    enum CustomerKeys: CodingKey {
        case customFields
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let customerContainer = try container.nestedContainer(keyedBy: CustomerKeys.self, forKey: .customer)
        
        self.consumerContact = try container.decode(ContactDTO.self, forKey: .consumerContact)
        self.messages = try container.decode([MessageDTO].self, forKey: .messages)
        self.inboxAssignee = try container.decodeIfPresent(AgentDTO.self, forKey: .inboxAssignee)
        self.thread = try container.decode(ReceivedThreadDataDTO.self, forKey: .thread)
        self.messagesScrollToken = try container.decode(String.self, forKey: .messagesScrollToken)
        self.customerContactFields = try customerContainer.decode([CustomFieldDTO].self, forKey: .customFields)
        
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        var customerContainer = container.nestedContainer(keyedBy: CustomerKeys.self, forKey: .customer)
        
        try container.encode(consumerContact, forKey: .consumerContact)
        try container.encode(messages, forKey: .messages)
        try container.encodeIfPresent(inboxAssignee, forKey: .inboxAssignee)
        try container.encode(thread, forKey: .thread)
        try container.encode(messagesScrollToken, forKey: .messagesScrollToken)
        try customerContainer.encode(customerContactFields, forKey: .customFields)
    }
}
