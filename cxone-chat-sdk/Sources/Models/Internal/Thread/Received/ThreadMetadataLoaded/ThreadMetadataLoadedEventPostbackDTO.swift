import Foundation

struct ThreadMetadataLoadedEventPostbackDTO: Decodable {
    
    let eventType: EventType

    let data: ThreadMetadataLoadedEventPostbackDataDTO
}
