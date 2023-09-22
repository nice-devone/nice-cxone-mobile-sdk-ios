import Foundation

/// The types of data that can be sent on an event.
enum EventDataType {
    
    // MARK: - Thread/Case
    
    case archiveThreadData(ThreadEventDataDTO)
    
    case loadThreadData(ThreadEventDataDTO)
    
    case updateThreadData(ThreadEventDataDTO)
    
    case setContactCustomFieldsData(SetContactCustomFieldsEventDataDTO)
    
    // MARK: - Customer
    
    case setCustomerCustomFieldData(CustomerCustomFieldsDataDTO)
    
    case customerTypingData(CustomerTypingEventDataDTO)
    
    case authorizeCustomerData(AuthorizeCustomerEventDataDTO)
    
    case reconnectCustomerData(ReconnectCustomerEventDataDTO)
    
    case refreshTokenPayload(RefreshTokenPayloadDataDTO)
    
    // MARK: - Message
    
    case sendMessageData(SendMessageEventDataDTO)
    
    case messageSeenByCustomer(ThreadEventDataDTO)
    
    case loadMoreMessageData(LoadMoreMessagesEventDataDTO)
    
    case sendOutboundMessageData(SendOutboundMessageEventDataDTO)

    // MARK: - Visitor
    
    case visitorEvent(VisitorsEventsDTO)
    
    case storeVisitorPayload(VisitorDTO)
}

// MARK: - Encodable

extension EventDataType: Encodable {
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        
        switch self {
        case .sendMessageData(let message):
            try container.encode(message)
        case .archiveThreadData(let thread):
            try container.encode(thread)
        case .loadThreadData(let thread):
            try container.encode(thread)
        case .loadMoreMessageData(let moreMessageData):
            try container.encode(moreMessageData)
        case .setContactCustomFieldsData(let data):
            try container.encode(data)
        case .setCustomerCustomFieldData(let data):
            try container.encode(data)
        case .customerTypingData(let data):
            try container.encode(data)
        case .authorizeCustomerData(let data):
            try container.encode(data)
        case .reconnectCustomerData(let data):
            try container.encode(data)
        case .updateThreadData(let data):
            try container.encode(data)
        case .refreshTokenPayload(let data):
            try container.encode(data)
        case .sendOutboundMessageData(let data):
            try container.encode(data)
        case .messageSeenByCustomer(let data):
            try container.encode(data)
        case .visitorEvent(let data):
            try container.encode(data)
        case .storeVisitorPayload(let data):
            try container.encode(data)
        }
    }
}
