import Foundation

struct InternalServerError: LocalizedError {
    
    let eventId: UUID

    let error: OperationError

    let thread: ThreadDTO?
}

extension InternalServerError: Decodable {
    
    enum CodingKeys: CodingKey {
        case eventId
        case error
        case inputData
    }
    
    enum InputDataCodingKeys: CodingKey {
        case thread
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let inputDataContainer = try container.nestedContainer(keyedBy: InputDataCodingKeys.self, forKey: .inputData)
        
        self.eventId = try container.decode(UUID.self, forKey: .eventId)
        self.error = try container.decode(OperationError.self, forKey: .error)
        self.thread = try inputDataContainer.decodeIfPresent(ThreadDTO.self, forKey: .thread)
    }
}
