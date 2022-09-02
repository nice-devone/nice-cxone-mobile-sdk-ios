import Foundation

struct MoreMessagesLoadedEventPostback: Codable {
    let eventType: EventType
    let data: MoreMessagesLoadedEventPostbackData
}
