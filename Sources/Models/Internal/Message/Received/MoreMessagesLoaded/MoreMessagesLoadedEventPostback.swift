import Foundation


struct MoreMessagesLoadedEventPostbackDTO: Codable {
    
    let eventType: EventType

    let data: MoreMessagesLoadedEventPostbackDataDTO
}
