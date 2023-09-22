import Foundation

struct SendOutboundMessageEventDataDTO {
    
    // MARK: - Properties
    
    let thread: ThreadDTO

    let contentType: MessageContentDTOType

    let idOnExternalPlatform: UUID

    let contactCustomFields: [CustomFieldDTO]

    let attachments: [AttachmentDTO]

    let deviceFingerprint: DeviceFingerprintDTO

    let token: String?
    
    // MARK: - Init
    
    init(
        thread: ThreadDTO,
        contentType: MessageContentDTOType,
        idOnExternalPlatform: UUID,
        contactCustomFields: [CustomFieldDTO],
        attachments: [AttachmentDTO],
        deviceFingerprint: DeviceFingerprintDTO,
        token: String?
    ) {
        self.thread = thread
        self.contentType = contentType
        self.idOnExternalPlatform = idOnExternalPlatform
        self.contactCustomFields = contactCustomFields
        self.attachments = attachments
        self.deviceFingerprint = deviceFingerprint
        self.token = token
    }
}

// MARK: - Encodable

extension SendOutboundMessageEventDataDTO: Encodable {
    
    enum CodingKeys: String, CodingKey {
        case thread
        case messageContent
        case idOnExternalPlatform
        case contact = "consumerContact"
        case attachments
        case deviceFingerprint = "browserFingerprint"
        case accessToken
    }
    
    enum AccessTokenCodingKey: CodingKey {
        case token
    }
    
    enum ContactCustomFieldsCodingKey: CodingKey {
        case customFields
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        var contactCustomFieldsContainer = container.nestedContainer(keyedBy: ContactCustomFieldsCodingKey.self, forKey: .contact)
        
        try container.encode(thread, forKey: .thread)
        try container.encode(contentType, forKey: .messageContent)
        try container.encode(idOnExternalPlatform, forKey: .idOnExternalPlatform)
        try contactCustomFieldsContainer.encode(contactCustomFields, forKey: .customFields)
        try container.encode(attachments, forKey: .attachments)
        try container.encode(deviceFingerprint, forKey: .deviceFingerprint)
        
        if let token = token, !token.isEmpty {
            var accessTokenContainer = container.nestedContainer(keyedBy: AccessTokenCodingKey.self, forKey: .accessToken)
            
            try accessTokenContainer.encode(token, forKey: .token)
        }
    }
}
