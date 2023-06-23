@testable import CXoneChatSDK


extension GenericEventPostbackDTO: Encodable {
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        
        try container.encodeIfPresent(eventType, forKey: .eventType)
        
        if let threads = threads, !threads.isEmpty {
            var receivedThreadsContainer = container.nestedContainer(keyedBy: ReceivedThreadsKeys.self, forKey: .data)
            
            try receivedThreadsContainer.encodeIfPresent(threads, forKey: .threads)
        }
    }
}
