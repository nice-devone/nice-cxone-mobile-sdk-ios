import Foundation


/// Represents statistics about the user.
public struct UserStatistics {
    
    /// The date at which the message was seen. Will be null if not yet seen.
    public let seenAt: Date?
    
    /// The date at which the message was read. Will be null if not yet read.
    public let readAt: Date?
}
