import Foundation

enum MessagePluginMapper {
    
    static func map(_ entity: MessagePlugin) throws -> MessagePluginDTO {
        MessagePluginDTO(text: entity.text, postback: entity.postback, element: try PluginMessageTypeMapper.map(entity.element))
    }
    
    static func map(_ entity: MessagePluginDTO) -> MessagePlugin {
        MessagePlugin(text: entity.text, postback: entity.postback, element: PluginMessageTypeMapper.map(entity.element))
    }
}
