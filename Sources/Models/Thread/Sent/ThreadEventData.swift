import Foundation

/// Event data to be sent for any thread event (archive, recover, etc.).
struct ThreadEventData: Codable {
    var thread: Thread
}
