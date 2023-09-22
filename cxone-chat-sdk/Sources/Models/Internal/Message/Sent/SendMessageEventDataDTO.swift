import Foundation

struct SendMessageEventDataDTO {
    
    // MARK: - Properties
    
    let thread: ThreadDTO

    let contentType: MessageContentDTOType

    let idOnExternalPlatform: UUID

    /// User specific custom fields
    let customer: CustomerCustomFieldsDataDTO

    /// Case specific custom fields
    let contact: ContactCustomFieldsDataDTO

    let attachments: [AttachmentDTO]

    let deviceFingerprint: DeviceFingerprintDTO

    let token: String?
    
    // MARK: - Init
    
    init(
        thread: ThreadDTO,
        contentType: MessageContentDTOType,
        idOnExternalPlatform: UUID,
        customer: CustomerCustomFieldsDataDTO,
        contact: ContactCustomFieldsDataDTO,
        attachments: [AttachmentDTO],
        deviceFingerprint: DeviceFingerprintDTO,
        token: String?
    ) {
        self.thread = thread
        self.contentType = contentType
        self.idOnExternalPlatform = idOnExternalPlatform
        self.customer = customer
        self.contact = contact
        self.attachments = attachments
        self.deviceFingerprint = deviceFingerprint
        self.token = token
    }
}

// MARK: - Codable

extension SendMessageEventDataDTO: Codable {

    enum CodingKeys: CodingKey {
        case thread
        case messageContent
        case idOnExternalPlatform
        case customer
        case contact
        case attachments
        case deviceFingerprint
        case accessToken
    }
    
    enum AccessTokenCodingKey: CodingKey {
        case token
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let accessTokenContainer = try? container.nestedContainer(keyedBy: AccessTokenCodingKey.self, forKey: .accessToken)
        
        self.thread = try container.decode(ThreadDTO.self, forKey: .thread)
        self.contentType = try container.decode(MessageContentDTOType.self, forKey: .messageContent)
        self.idOnExternalPlatform = try container.decode(UUID.self, forKey: .idOnExternalPlatform)
        self.customer = try container.decode(CustomerCustomFieldsDataDTO.self, forKey: .customer)
        self.contact = try container.decode(ContactCustomFieldsDataDTO.self, forKey: .contact)
        self.attachments = try container.decode([AttachmentDTO].self, forKey: .attachments)
        self.deviceFingerprint = try container.decode(DeviceFingerprintDTO.self, forKey: .deviceFingerprint)
        self.token = try accessTokenContainer?.decodeIfPresent(String.self, forKey: .token)
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        
        try container.encode(thread, forKey: .thread)
        try container.encode(contentType, forKey: .messageContent)
        try container.encode(idOnExternalPlatform, forKey: .idOnExternalPlatform)
        try container.encode(customer, forKey: .customer)
        try container.encode(contact, forKey: .contact)
        try container.encode(attachments, forKey: .attachments)
        try container.encode(deviceFingerprint, forKey: .deviceFingerprint)
        
        if let token = token, !token.isEmpty {
            var accessTokenContainer = container.nestedContainer(keyedBy: AccessTokenCodingKey.self, forKey: .accessToken)
            
            try accessTokenContainer.encodeIfPresent(token, forKey: .token)
        }
        
    }
}
