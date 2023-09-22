import Foundation

/// All info about data of a received thread.
struct ReceivedThreadDataDTO {
    
    // MARK: - Properties

    /// The unique identifier of the data in the external platform.
    let idOnExternalPlatform: UUID

    /// The unique identifier of the channel.
    let channelId: String

    /// The name given to the thread (for multi-thread channels only).
    let threadName: String

    /// The flag whenever more messages can be added.
    let canAddMoreMessages: Bool
    
    // MARK: - Init
    
    init(
        idOnExternalPlatform: UUID,
        channelId: String,
        threadName: String,
        canAddMoreMessages: Bool
    ) {
        self.idOnExternalPlatform = idOnExternalPlatform
        self.channelId = channelId
        self.threadName = threadName
        self.canAddMoreMessages = canAddMoreMessages
    }
}

// MARK: - Decodable

extension ReceivedThreadDataDTO: Decodable {
    
    enum CodingKeys: CodingKey {
        case idOnExternalPlatform
        case channelId
        case threadName
        case canAddMoreMessages
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        self.idOnExternalPlatform = try container.decode(UUID.self, forKey: .idOnExternalPlatform)
        self.channelId = try container.decode(String.self, forKey: .channelId)
        self.threadName = try container.decode(String.self, forKey: .threadName)
        self.canAddMoreMessages = try container.decode(Bool.self, forKey: .canAddMoreMessages)
    }
}
