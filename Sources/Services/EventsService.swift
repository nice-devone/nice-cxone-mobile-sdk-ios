import Foundation


final class EventsService {
    
    // MARK: - Properties
    
    private let encoder = JSONEncoder()
    
    var connectionContext: ConnectionContext
    
    
    // MARK: - Init
    
    init(connectionContext: ConnectionContext) {
        self.connectionContext = connectionContext
    }
    
    
    // MARK: - Methods
    
    func create(_ eventType: EventType, with eventData: EventDataType? = nil) throws -> Data {
        LogManager.trace("Creating an event of type - \(eventType).")
        
        var event = EventDTO(
            brandId: connectionContext.brandId,
            channelId: connectionContext.channelId,
            customerIdentity: try getCustomerIdentity(nameless: eventType != .sendMessage),
            eventType: eventType,
            data: eventData
        )
        
        if eventType == .reconnectCustomer {
            guard let visitorId = connectionContext.visitorId else {
                throw CXoneChatError.unsupportedChannelConfig
            }
            
            event.payload.visitorId = LowerCaseUUID(uuid: visitorId)
        }
        
        return try encoder.encode(event)
    }
}


// MARK: - Private methods

private extension EventsService {
    
    func getCustomerIdentity(nameless: Bool = true) throws -> CustomerIdentityDTO {
        LogManager.trace("Getting customer identity.")
        
        guard let customer = connectionContext.customer else {
            throw CXoneChatError.unsupportedChannelConfig
        }
        
        return .init(
            idOnExternalPlatform: customer.idOnExternalPlatform,
            firstName: nameless ? nil : customer.firstName,
            lastName: nameless ? nil : customer.lastName
        )
    }
}
