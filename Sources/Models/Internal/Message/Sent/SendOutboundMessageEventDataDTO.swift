import Foundation


struct SendOutboundMessageEventDataDTO: Codable {
    
    // MARK: - Properties
    
    let thread: ThreadDTO

    let contentType: MessageContentDTOType

    let idOnExternalPlatform: UUID

    let consumerContact: ContactCustomFieldsDataDTO

    let attachments: [AttachmentDTO]

    let browserFingerprint: BrowserFingerprintDTO

    let token: String?
    
    
    // MARK: - Init
    
    init(
        thread: ThreadDTO,
        contentType: MessageContentDTOType,
        idOnExternalPlatform: UUID,
        consumerContact: ContactCustomFieldsDataDTO,
        attachments: [AttachmentDTO],
        browserFingerprint: BrowserFingerprintDTO,
        token: String?
    ) {
        self.thread = thread
        self.contentType = contentType
        self.idOnExternalPlatform = idOnExternalPlatform
        self.consumerContact = consumerContact
        self.attachments = attachments
        self.browserFingerprint = browserFingerprint
        self.token = token
    }
    
    
    // MARK: - Codable
    
    enum CodingKeys: CodingKey {
        case thread
        case messageContent
        case idOnExternalPlatform
        case consumerContact
        case attachments
        case browserFingerprint
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
        self.consumerContact = try container.decode(ContactCustomFieldsDataDTO.self, forKey: .consumerContact)
        self.attachments = try container.decode([AttachmentDTO].self, forKey: .attachments)
        self.browserFingerprint = try container.decode(BrowserFingerprintDTO.self, forKey: .browserFingerprint)
        self.token = try accessTokenContainer?.decodeIfPresent(String.self, forKey: .token)
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        
        try container.encode(thread, forKey: .thread)
        try container.encode(contentType, forKey: .messageContent)
        try container.encode(idOnExternalPlatform, forKey: .idOnExternalPlatform)
        try container.encode(consumerContact, forKey: .consumerContact)
        try container.encode(attachments, forKey: .attachments)
        try container.encode(browserFingerprint, forKey: .browserFingerprint)
        
        if let token = token, !token.isEmpty {
            var accessTokenContainer = container.nestedContainer(keyedBy: AccessTokenCodingKey.self, forKey: .accessToken)
            
            try accessTokenContainer.encode(token, forKey: .token)
        }
    }
}
