import Foundation


// ThreadView

/// Represents info about a thread from the socket.
struct ThreadDTO: Codable {
    
    /// The unique id for the thread.
    let idOnExternalPlatform: UUID
    
    /// The name given to the thread (for multi-chat channels only).
    let threadName: String?
}
