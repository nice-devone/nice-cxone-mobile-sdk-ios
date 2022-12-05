import Foundation


/// The types of data that can be sent on an event.
enum EventDataType: Encodable {
    
    case archiveThreadData(ThreadEventDataDTO)
    
    case loadThreadData(ThreadEventDataDTO)
    
    case sendMessageData(SendMessageEventDataDTO)
    
    case sendOutboundMessageData(SendOutboundMessageEventDataDTO)
    
    case loadMoreMessageData(LoadMoreMessagesEventDataDTO)
    
    case setContactCustomFieldsData(SetContactCustomFieldsEventDataDTO)
    
    case setCustomerCustomFieldData(CustomerCustomFieldsDataDTO)
    
    case customerTypingData(CustomerTypingEventDataDTO)
    
    case authorizeCustomerData(AuthorizeCustomerEventDataDTO)
    
    case reconnectCustomerData(ReconnectCustomerEventDataDTO)
    
    case updateThreadData(ThreadEventDataDTO)
    
    case refreshTokenPayload(RefreshTokenPayloadDataDTO)
    
    
    // MARK: - Encoder
    
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
        }
    }
}
