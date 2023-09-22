import Foundation

enum MessageSubElementMapper {
    
    static func map(from type: MessageSubElementType) -> MessageSubElementDTOType {
        switch type {
        case .replyButton(let entity):
            return .replyButton(MessageReplyButtonMapper.map(from: entity))
        }
    }
    
    static func map(from type: MessageSubElementDTOType) -> MessageSubElementType {
        switch type {
        case .replyButton(let entity):
            return .replyButton(MessageReplyButtonMapper.map(from: entity))
        }
    }
}
