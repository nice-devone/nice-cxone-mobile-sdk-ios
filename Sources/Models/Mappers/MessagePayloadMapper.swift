import Foundation


enum MessagePayloadMapper {
    
    static func map(_ entity: MessagePayload) throws -> MessagePayloadDTO {
        .init(text: entity.text, postback: entity.postback, element: try PluginMessageTypeMapper.map(entity.element))
        
    }
    
    static func map(_ entity: MessagePayloadDTO) -> MessagePayload {
        .init(text: entity.text, postback: entity.postback, element: PluginMessageTypeMapper.map(entity.element))
    }
}
