import Foundation

/// The types of data that can be sent on an event.
enum EventData: Encodable {
    case archiveThreadData(ThreadEventData)
    case loadThreadData(ThreadEventData)
    case sendMessageData(SendMessageEventData)
    case sendOutboundMessageData(SendOutboundMessageEventData)
    case loadMoreMessageData(LoadMoreMessagesEventData)
    case setContactCustomFieldsData(SetContactCustomFieldsEventData)
    case setCustomerCustomFieldData(CustomFieldsData)
    case customerTypingData(CustomerTypingEventData)
    case authorizeCustomerData(AuthorizeCustomerEventData)
    case reconnectCustomerData(ReconnectCustomerEventData)
    case updateThreadData(ThreadEventData)
    case refreshTokenPayload(RefreshTokenPayloadData)
    
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
