import Foundation

struct ThreadMetadataLoadedEventPostback: Codable {
    let eventType: EventType
    let data: ThreadMetadataLoadedEventPostbackData
}
