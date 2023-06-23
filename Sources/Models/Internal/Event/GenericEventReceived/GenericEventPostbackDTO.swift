import Foundation


/// Represents info about a postback of a generic event.
struct GenericEventPostbackDTO {
    
    // MARK: - Properties
    
    /// The type of the event.
    let eventType: EventType?

    /// The data of the received threads.
    let threads: [ReceivedThreadDataDTO]?
    
    
    // MARK: - Init
    
    init(eventType: EventType?, threads: [ReceivedThreadDataDTO]?) {
        self.eventType = eventType
        self.threads = threads
    }
}


// MARK: - Decodable

extension GenericEventPostbackDTO: Decodable {
    
    enum CodingKeys: CodingKey {
        case eventType
        case data
    }
    
    enum ReceivedThreadsKeys: CodingKey {
        case threads
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let receivedThreadsContainer = try? container.nestedContainer(keyedBy: ReceivedThreadsKeys.self, forKey: .data)
        
        self.eventType = try container.decodeIfPresent(EventType.self, forKey: .eventType)
        self.threads = try receivedThreadsContainer?.decodeIfPresent([ReceivedThreadDataDTO].self, forKey: .threads)
    }
}
