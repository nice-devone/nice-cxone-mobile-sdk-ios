import Foundation


/// Event received when thread metadata has been loaded.
struct ThreadMetadataLoadedEventDTO: Codable {
    
    let eventId: UUID

    let postback: ThreadMetadataLoadedEventPostbackDTO
}
