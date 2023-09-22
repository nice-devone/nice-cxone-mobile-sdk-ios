import Foundation

enum MessagePayloadMapper {
    
    static func map(_ entity: MessagePayload) -> MessagePayloadDTO {
        MessagePayloadDTO(text: entity.text, postback: entity.postback)
    }
    
    static func map(_ entity: MessagePayloadDTO) -> MessagePayload {
        MessagePayload(text: entity.text, postback: entity.postback)
    }
}
