import Foundation

public struct UserStatistics: Codable {
    
    /// The date at which the message was seen. Will be null if not yet seen.
    public var seenAt: String? // TODO: Change type to Date
    
    /// The date at which the message was read. Will be null if not yet read.
    public var readAt: String? // TODO: Change type to Date
}
