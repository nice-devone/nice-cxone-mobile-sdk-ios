import Foundation


enum MessagePayloadMapper {
    
    static func map(_ entity: MessagePayload) -> MessagePayloadDTO {
        .init(text: entity.text, elements: entity.elements.map(MessageElementMapper.map))
    }
    
    static func map(_ entity: MessagePayloadDTO) -> MessagePayload {
        .init(text: entity.text, elements: entity.elements.map(MessageElementMapper.map))
    }
}
