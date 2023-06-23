import Foundation


struct ExecuteTriggerEventPayloadDTO {
    
    // MARK: - Properties
    
    let eventType: EventType
    
    let brand: BrandDTO
    
    let channel: ChannelIdentifierDTO
    
    let customerIdentity: CustomerIdentityDTO
    
    let eventId: LowerCaseUUID
    
    let visitorId: LowerCaseUUID
    
    let triggerId: LowerCaseUUID
    
    
    // MARK: - Init
    
    init(
        eventType: EventType,
        brand: BrandDTO,
        channel: ChannelIdentifierDTO,
        customerIdentity: CustomerIdentityDTO,
        eventId: LowerCaseUUID,
        visitorId: LowerCaseUUID,
        triggerId: LowerCaseUUID
    ) {
        self.eventType = eventType
        self.brand = brand
        self.channel = channel
        self.customerIdentity = customerIdentity
        self.eventId = eventId
        self.visitorId = visitorId
        self.triggerId = triggerId
    }
}


// MARK: - Encodable

extension ExecuteTriggerEventPayloadDTO: Encodable {
    
    enum CodingKeys: CodingKey {
        case eventType
        case brand
        case channel
        case customerIdentity
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
    }
    
    enum TriggerKeys: CodingKey {
        case id
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        var destinationContainer = container.nestedContainer(keyedBy: DestinationKeys.self, forKey: .destination)
        var visitorContainer = container.nestedContainer(keyedBy: VisitorKeys.self, forKey: .visitor)
        var triggerDataContainer = container.nestedContainer(keyedBy: TriggerDataKeys.self, forKey: .data)
        var triggerContainer = triggerDataContainer.nestedContainer(keyedBy: TriggerKeys.self, forKey: .trigger)
        
        try container.encode(eventType, forKey: .eventType)
        try container.encode(brand, forKey: .brand)
        try container.encode(channel, forKey: .channel)
        try container.encode(customerIdentity, forKey: .customerIdentity)
        try destinationContainer.encode(eventId, forKey: .id)
        try visitorContainer.encode(visitorId, forKey: .id)
        try triggerContainer.encode(triggerId, forKey: .id)
    }
}
