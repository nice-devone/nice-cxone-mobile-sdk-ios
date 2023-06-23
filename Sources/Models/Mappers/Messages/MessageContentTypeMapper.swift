import Foundation


enum MessageContentTypeMapper {
    
    static func map(_ entity: MessageContentType) throws -> MessageContentDTOType {
        switch entity {
        case .text(let entity):
            return .text(MessagePayloadMapper.map(entity))
        case .plugin(let entity):
            return .plugin(try MessagePluginMapper.map(entity))
        case .richLink(let entity):
            return .richLink(MessageRichLinkMapper.map(from: entity))
        case .quickReplies(let entity):
            return .quickReplies(MessageQuickRepliesMapper.map(from: entity))
        case .listPicker(let entity):
            return .listPicker(MessageListPickerMapper.map(from: entity))
        case .unknown:
            return .unknown
        }
    }
    
    static func map(_ entity: MessageContentDTOType) -> MessageContentType {
        switch entity {
        case .text(let entity):
            return .text(MessagePayloadMapper.map(entity))
        case .plugin(let entity):
            return .plugin(MessagePluginMapper.map(entity))
        case .richLink(let entity):
            return .richLink(MessageRichLinkMapper.map(from: entity))
        case .quickReplies(let entity):
            return .quickReplies(MessageQuickRepliesMapper.map(from: entity))
        case .listPicker(let entity):
            return .listPicker(MessageListPickerMapper.map(from: entity))
        case .unknown:
            return .unknown
        }
    }
}
