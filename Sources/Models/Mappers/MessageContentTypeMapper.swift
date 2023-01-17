import Foundation


enum MessageContentTypeMapper {
    
    static func map(_ entity: MessageContentType) throws -> MessageContentDTOType {
        switch entity {
        case .text(let string):
            return .text(string)
        case .plugin(let payload):
            return .plugin(try MessagePayloadMapper.map(payload))
        case .unknown:
            return .unknown
        }
    }
    
    static func map(_ entity: MessageContentDTOType) -> MessageContentType {
        switch entity {
        case .text(let string):
            return .text(string)
        case .plugin(let payload):
            return .plugin(MessagePayloadMapper.map(payload))
        case .unknown:
            return .unknown
        }
    }
}
