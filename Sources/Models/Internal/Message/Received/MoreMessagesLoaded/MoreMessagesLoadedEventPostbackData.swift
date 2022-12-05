import Foundation


struct MoreMessagesLoadedEventPostbackDataDTO: Codable {
    
    let messages: [MessageDTO]

    let scrollToken: String
}
