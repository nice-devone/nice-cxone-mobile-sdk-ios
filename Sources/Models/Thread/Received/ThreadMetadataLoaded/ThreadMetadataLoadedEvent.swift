import Foundation

/// Event received when thread metadata has been loaded.
struct ThreadMetadataLoadedEvent: Codable {
    let eventId: UUID
    let postback: ThreadMetadataLoadedEventPostback
}
