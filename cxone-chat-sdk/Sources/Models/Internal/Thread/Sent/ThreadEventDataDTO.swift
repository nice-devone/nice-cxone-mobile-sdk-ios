import Foundation

/// Event data to be sent for any thread event (archive, recover, etc.).
struct ThreadEventDataDTO: Codable {
    
    let thread: ThreadDTO
}
