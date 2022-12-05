import Foundation


struct ThreadMetadataLoadedEventPostbackDTO: Codable {
    
    let eventType: EventType

    let data: ThreadMetadataLoadedEventPostbackDataDTO
}
