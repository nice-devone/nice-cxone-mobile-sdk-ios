@testable import CXoneChatSDK


extension ExecuteTriggerEventPayloadDTO: Decodable {
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let destinationContainer = try container.nestedContainer(keyedBy: DestinationKeys.self, forKey: .destination)
        let visitorContainer = try container.nestedContainer(keyedBy: VisitorKeys.self, forKey: .visitor)
        let triggerContainer = try container
            .nestedContainer(keyedBy: TriggerDataKeys.self, forKey: .data)
            .nestedContainer(keyedBy: TriggerKeys.self, forKey: .trigger)
        
        self.init(
            eventType: try container.decode(EventType.self, forKey: .eventType),
            brand: try container.decode(BrandDTO.self, forKey: .brand),
            channel: try container.decode(ChannelIdentifierDTO.self, forKey: .channel),
            customerIdentity: try container.decode(CustomerIdentityDTO.self, forKey: .customerIdentity),
            eventId: try destinationContainer.decode(LowerCaseUUID.self, forKey: .id),
            visitorId: try visitorContainer.decode(LowerCaseUUID.self, forKey: .id),
            triggerId: try triggerContainer.decode(LowerCaseUUID.self, forKey: .id)
        )
    }
}
