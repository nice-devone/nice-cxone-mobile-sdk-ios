import Foundation


/// All info about data of a received thread.
struct ReceivedThreadDataDTO: Codable {
    
    // MARK: - Properties

    /// The unique identifier of the data.
    ///
    /// It combines an unique identifier of the channel and `UUID`.
    let id: String

    /// The unique identifier of the data in the external platform.
    let idOnExternalPlatform: UUID

    /// The unique identifier of the channel.
    let channelId: String

    /// The name given to the thread (for multi-thread channels only).
    let threadName: String

    /// The timestamp of when the message was created.
    let createdAt: Date

    /// The timestamp of when the mssage was updated.
    let updatedAt: Date

    /// The flag whenever more messages can be added.
    let canAddMoreMessages: Bool
    
    
    // MARK: - Init
    
    init(
        id: String,
        idOnExternalPlatform: UUID,
        channelId: String,
        threadName: String,
        createdAt: Date,
        updatedAt: Date,
        canAddMoreMessages: Bool
    ) {
        self.id = id
        self.idOnExternalPlatform = idOnExternalPlatform
        self.channelId = channelId
        self.threadName = threadName
        self.createdAt = createdAt
        self.updatedAt = updatedAt
        self.canAddMoreMessages = canAddMoreMessages
    }
    
    
    // MARK: - Codable
    
    enum CodingKeys: CodingKey {
        case id
        case idOnExternalPlatform
        case channelId
        case threadName
        case createdAt
        case updatedAt
        case canAddMoreMessages
    }
    
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        self.id = try container.decode(String.self, forKey: .id)
        self.idOnExternalPlatform = try container.decode(UUID.self, forKey: .idOnExternalPlatform)
        self.channelId = try container.decode(String.self, forKey: .channelId)
        self.threadName = try container.decode(String.self, forKey: .threadName)
        self.createdAt = try container.decodeISODate(forKey: .createdAt)
        self.updatedAt = try container.decodeISODate(forKey: .updatedAt)
        self.canAddMoreMessages = try container.decode(Bool.self, forKey: .canAddMoreMessages)
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        
        try container.encode(id, forKey: .id)
        try container.encode(idOnExternalPlatform, forKey: .idOnExternalPlatform)
        try container.encode(channelId, forKey: .channelId)
        try container.encode(threadName, forKey: .threadName)
        try container.encodeISODate(createdAt, forKey: .createdAt)
        try container.encodeISODate(updatedAt, forKey: .updatedAt)
        try container.encode(canAddMoreMessages, forKey: .canAddMoreMessages)
    }
}
