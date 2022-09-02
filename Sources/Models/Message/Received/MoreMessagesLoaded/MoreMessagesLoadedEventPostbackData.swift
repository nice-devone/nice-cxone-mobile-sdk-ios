import Foundation

struct MoreMessagesLoadedEventPostbackData: Codable {
    let messages: [Message]
    let scrollToken: String
}
