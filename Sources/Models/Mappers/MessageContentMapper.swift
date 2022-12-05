import Foundation


enum MessageContentMapper {
    
    static func map(_ entity: MessageContent) -> MessageContentDTO {
        .init(type: entity.type, payload: MessagePayloadMapper.map(entity.payload), fallbackText: entity.fallbackText)
    }
    
    static func map(_ entity: MessageContentDTO) -> MessageContent {
        .init(type: entity.type, payload: MessagePayloadMapper.map(entity.payload), fallbackText: entity.fallbackText)
    }
}
