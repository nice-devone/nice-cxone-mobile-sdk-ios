import Foundation


/// Represents info about a postback of a generic event.
struct GenericEventPostbackDTO: Codable {
    
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
    
    
    // MARK: - Codable
    
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
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        
        try container.encodeIfPresent(eventType, forKey: .eventType)
        
        if let threads = threads, !threads.isEmpty {
            var receivedThreadsContainer = container.nestedContainer(keyedBy: ReceivedThreadsKeys.self, forKey: .data)
            
            try receivedThreadsContainer.encodeIfPresent(threads, forKey: .threads)
        }
    }
}
