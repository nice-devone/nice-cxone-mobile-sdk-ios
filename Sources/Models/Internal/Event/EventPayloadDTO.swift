import Foundation


/// The details about the event to be sent.
struct EventPayloadDTO: Encodable {
    
    // MARK: - Properties
    
    /// The brand for which the event applies.
    let brand: BrandDTO
    
    /// The channel for which the event applies.
    let channel: ChannelIdentifierDTO
    
    /// The identity of the customer that is sending the event.
    let consumerIdentity: CustomerIdentityDTO
    
    /// The type of event to be sent.
    let eventType: EventType
    
    /// The visitor to reconnect. Only used for the ReconnectCustomer event.
    var visitorId: LowerCaseUUID?
    
    /// The data to be sent for the event.
    let data: EventDataType?
    
    
    // MARK: - Init
    
    init(brandId: Int, channelId: String, customerIdentity: CustomerIdentityDTO, eventType: EventType, data: EventDataType?) {
        self.brand = .init(id: brandId)
        self.channel = .init(id: channelId)
        self.consumerIdentity = customerIdentity
        self.eventType = eventType
        self.data = data
    }
    
    
    // MARK: - Codable
    
    enum CodingKeys: CodingKey {
        case brand
        case channel
        case consumerIdentity
        case eventType
        case visitor
        case data
    }
    
    enum VisitorKeys: CodingKey {
        case id
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        
        try container.encode(brand, forKey: .brand)
        try container.encode(channel, forKey: .channel)
        try container.encode(consumerIdentity, forKey: .consumerIdentity)
        try container.encode(eventType, forKey: .eventType)
        try container.encodeIfPresent(data, forKey: .data)
        
        if let visitorId = visitorId {
            var visitorContainer = container.nestedContainer(keyedBy: VisitorKeys.self, forKey: .visitor)
            
            try visitorContainer.encodeIfPresent(visitorId, forKey: .id)
        }
    }
}
