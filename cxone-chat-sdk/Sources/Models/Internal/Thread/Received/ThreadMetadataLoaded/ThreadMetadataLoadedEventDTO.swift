import Foundation

/// Event received when thread metadata has been loaded.
struct ThreadMetadataLoadedEventDTO: Decodable {
    
    let eventId: UUID

    let postback: ThreadMetadataLoadedEventPostbackDTO
}
