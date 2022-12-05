import Foundation


struct ExecuteTriggerEventPayloadDTO: Codable {
    
    // MARK: - Properties
    
    let eventType: EventType
    
    let brand: BrandDTO
    
    let channel: ChannelIdentifierDTO
    
    let consumerIdentity: CustomerIdentityDTO
    
    let eventId: LowerCaseUUID
    
    let visitorId: LowerCaseUUID
    
    let triggerId: LowerCaseUUID
    
    
    // MARK: - Init
    
    init(
        eventType: EventType,
        brand: BrandDTO,
        channel: ChannelIdentifierDTO,
        consumerIdentity: CustomerIdentityDTO,
        eventId: LowerCaseUUID,
        visitorId: LowerCaseUUID,
        triggerId: LowerCaseUUID
    ) {
        self.eventType = eventType
        self.brand = brand
        self.channel = channel
        self.consumerIdentity = consumerIdentity
        self.eventId = eventId
        self.visitorId = visitorId
        self.triggerId = triggerId
    }
    
    
    // MARK: - Codable
    
    enum CodingKeys: CodingKey {
        case eventType
        case brand
        case channel
        case consumerIdentity
        case destination
        case visitor
        case data
    }
    
    enum DestinationKeys: CodingKey {
        case id
    }
    
    enum VisitorKeys: CodingKey {
        case id
    }
    
    enum TriggerDataKeys: CodingKey {
        case trigger
        
        enum TriggerKeys: CodingKey {
            case id
        }
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let destinationContainer = try container.nestedContainer(keyedBy: DestinationKeys.self, forKey: .destination)
        let visitorContainer = try container.nestedContainer(keyedBy: VisitorKeys.self, forKey: .visitor)
        let triggerContainer = try container
            .nestedContainer(keyedBy: TriggerDataKeys.self, forKey: .data)
            .nestedContainer(keyedBy: TriggerDataKeys.TriggerKeys.self, forKey: .trigger)
        
        
        self.eventType = try container.decode(EventType.self, forKey: .eventType)
        self.brand = try container.decode(BrandDTO.self, forKey: .brand)
        self.channel = try container.decode(ChannelIdentifierDTO.self, forKey: .channel)
        self.consumerIdentity = try container.decode(CustomerIdentityDTO.self, forKey: .consumerIdentity)
        self.eventId = try destinationContainer.decode(LowerCaseUUID.self, forKey: .id)
        self.visitorId = try visitorContainer.decode(LowerCaseUUID.self, forKey: .id)
        self.triggerId = try triggerContainer.decode(LowerCaseUUID.self, forKey: .id)
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        var destinationContainer = container.nestedContainer(keyedBy: DestinationKeys.self, forKey: .destination)
        var visitorContainer = container.nestedContainer(keyedBy: VisitorKeys.self, forKey: .visitor)
        var triggerDataContainer = container.nestedContainer(keyedBy: TriggerDataKeys.self, forKey: .data)
        var triggerContainer = triggerDataContainer.nestedContainer(keyedBy: TriggerDataKeys.TriggerKeys.self, forKey: .trigger)
        
        try container.encode(eventType, forKey: .eventType)
        try container.encode(brand, forKey: .brand)
        try container.encode(channel, forKey: .channel)
        try container.encode(consumerIdentity, forKey: .consumerIdentity)
        try destinationContainer.encode(eventId, forKey: .id)
        try visitorContainer.encode(visitorId, forKey: .id)
        try triggerContainer.encode(triggerId, forKey: .id)
    }
}
