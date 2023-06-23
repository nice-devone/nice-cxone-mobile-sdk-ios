import Foundation


struct MoreMessagesLoadedEventPostbackDTO: Decodable {
    
    let eventType: EventType

    let data: MoreMessagesLoadedEventPostbackDataDTO
}
