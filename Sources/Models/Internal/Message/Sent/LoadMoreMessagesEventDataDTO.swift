import Foundation


/// Data payload for the load more messages event.
struct LoadMoreMessagesEventDataDTO: Encodable {
    
    // MARK: - Properties
    
    let scrollToken: String

    let thread: ThreadDTO

    let oldestMessageDatetime: Date
    
    
    // MARK: - Codable
    
    enum CodingKeys: CodingKey {
        case scrollToken
        case thread
        case oldestMessageDatetime
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        
        try container.encode(scrollToken, forKey: .scrollToken)
        try container.encode(thread, forKey: .thread)
        try container.encodeISODate(oldestMessageDatetime, forKey: .oldestMessageDatetime)
    }
}