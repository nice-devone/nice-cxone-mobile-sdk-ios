import Foundation


struct StoreVisitorEventsPayloadDTO: Encodable {
    
    // MARK: - Properties
    
    let eventType: EventType

    let brand: BrandDTO

    let visitorId: LowerCaseUUID

    let id: LowerCaseUUID

    let data: StoreVisitorEventDataType

    let channel: ChannelIdentifierDTO
    
    
    // MARK: - Codable
    
    enum CodingKeys: CodingKey {
        case eventType
        case brand
        case visitor
        case destination
        case data
        case channel
    }
    
    enum DestinationKeys: CodingKey {
        case id
    }
    
    enum VisitorKeys: CodingKey {
        case id
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        var destinationContainer = container.nestedContainer(keyedBy: DestinationKeys.self, forKey: .destination)
        var visitorContainer = container.nestedContainer(keyedBy: VisitorKeys.self, forKey: .visitor)
        
        try container.encode(eventType, forKey: .eventType)
        try container.encode(brand, forKey: .brand)
        try visitorContainer.encode(visitorId, forKey: .id)
        try destinationContainer.encode(id, forKey: .id)
        try container.encode(data, forKey: .data)
        try container.encode(channel, forKey: .channel)
    }
}
