import Foundation

// ThreadView

/// Represents info about a thread from the socket.
public struct Thread: Codable {
    
    /// The thread id. May not be present.
    internal var id: String?
    
    /// The unique id for the thread.
    public var idOnExternalPlatform: UUID
    
    /// The name given to the thread (for multi-chat channels only).
    public var threadName: String?
}
