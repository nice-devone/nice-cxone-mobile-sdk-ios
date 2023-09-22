import Foundation

/// Represents statistics about the user.
struct UserStatisticsDTO {
    
    // MARK: - Properties
    
    /// The date at which the message was seen. Will be null if not yet seen.
    let seenAt: Date?
    
    /// The date at which the message was read. Will be null if not yet read.
    let readAt: Date?
    
    // MARK: - Init
    
    init(seenAt: Date?, readAt: Date?) {
        self.seenAt = seenAt
        self.readAt = readAt
    }
}

// MARK: - Codable

extension UserStatisticsDTO: Codable {
    
    enum CodingKeys: CodingKey {
        case seenAt
        case readAt
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        self.seenAt = try container.decodeISODateIfPresent(forKey: .seenAt)
        self.readAt = try container.decodeISODateIfPresent(forKey: .readAt)
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        
        try container.encodeISODateIfPresent(seenAt, forKey: .seenAt)
        try container.encodeISODateIfPresent(readAt, forKey: .readAt)
    }
}
