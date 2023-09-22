import Foundation

struct MoreMessagesLoadedEventPostbackDataDTO: Decodable {
    
    let messages: [MessageDTO]

    let scrollToken: String
}
