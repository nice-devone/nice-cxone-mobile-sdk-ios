import Foundation


// MessageView

/// Represents all info about a message in a chat.
struct MessageDTO: Codable {
    
    // MARK: - Properties
    
    /// The unique id for the message.
    let idOnExternalPlatform: UUID
    
    /// The thread id for the message.
    let threadIdOnExternalPlatform: UUID
    
    /// The content of the message
    let contentType: MessageContentDTOType
    
    /// The timestamp of when the message was created.
    let createdAt: Date
    
    /// The attachments on the message.
    let attachments: [AttachmentDTO]
    
    /// The direction that the message is being sent (in regards to the agent).
    let direction: MessageDirectionType
    
    /// Statistic information about the message (read status, viewed status, etc.).
    let userStatistics: UserStatisticsDTO
    
    /// The agent that sent the message. Only present if the direction is outbound.
    let authorUser: AgentDTO?
    
    /// The customer that sent the message. Only present if the direction is inbound.
    let authorEndUserIdentity: CustomerIdentityDTO?
    
    
    // MARK: - Init
    
    init(
        idOnExternalPlatform: UUID,
        threadIdOnExternalPlatform: UUID,
        contentType: MessageContentDTOType,
        createdAt: Date,
        attachments: [AttachmentDTO],
        direction: MessageDirectionType,
        userStatistics: UserStatisticsDTO,
        authorUser: AgentDTO?,
        authorEndUserIdentity: CustomerIdentityDTO?
    ) {
        self.idOnExternalPlatform = idOnExternalPlatform
        self.threadIdOnExternalPlatform = threadIdOnExternalPlatform
        self.contentType = contentType
        self.createdAt = createdAt
        self.attachments = attachments
        self.direction = direction
        self.userStatistics = userStatistics
        self.authorUser = authorUser
        self.authorEndUserIdentity = authorEndUserIdentity
    }
    
    
    // MARK: - Codable
    
    enum CodingKeys: CodingKey {
        case idOnExternalPlatform
        case threadIdOnExternalPlatform
        case messageContent
        case createdAt
        case attachments
        case direction
        case userStatistics
        case authorUser
        case authorEndUserIdentity
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        self.idOnExternalPlatform = try container.decode(UUID.self, forKey: .idOnExternalPlatform)
        self.threadIdOnExternalPlatform = try container.decode(UUID.self, forKey: .threadIdOnExternalPlatform)
        self.createdAt = try container.decodeISODate(forKey: .createdAt)
        self.attachments = try container.decode([AttachmentDTO].self, forKey: .attachments)
        self.direction = try container.decode(MessageDirectionType.self, forKey: .direction)
        self.contentType = try container.decode(MessageContentDTOType.self, forKey: .messageContent)
        self.userStatistics = try container.decode(UserStatisticsDTO.self, forKey: .userStatistics)
        self.authorUser = try container.decodeIfPresent(AgentDTO.self, forKey: .authorUser)
        self.authorEndUserIdentity = try container.decodeIfPresent(CustomerIdentityDTO.self, forKey: .authorEndUserIdentity)
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        
        try container.encode(idOnExternalPlatform, forKey: .idOnExternalPlatform)
        try container.encode(threadIdOnExternalPlatform, forKey: .threadIdOnExternalPlatform)
        try container.encodeISODate(createdAt, forKey: .createdAt)
        try container.encode(attachments, forKey: .attachments)
        try container.encode(direction, forKey: .direction)
        try container.encode(contentType, forKey: .messageContent)
        try container.encode(userStatistics, forKey: .userStatistics)
        try container.encodeIfPresent(authorUser, forKey: .authorUser)
        try container.encodeIfPresent(authorEndUserIdentity, forKey: .authorEndUserIdentity)
    }
}
