@testable import CXoneChatSDK

extension InternalServerError: Encodable {
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        var inputDataContainer = container.nestedContainer(keyedBy: InputDataCodingKeys.self, forKey: .inputData)
        
        try container.encode(eventId, forKey: .eventId)
        try container.encode(error, forKey: .error)
        try inputDataContainer.encodeIfPresent(thread, forKey: .thread)
    }
}
