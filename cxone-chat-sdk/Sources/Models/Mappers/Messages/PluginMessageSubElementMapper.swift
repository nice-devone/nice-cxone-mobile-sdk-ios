import Foundation

enum PluginMessageSubElementMapper {
    
    static func map(_ entity: PluginMessageSubElementDTOType) -> PluginMessageSubElementType {
        switch entity {
        case .text(let entity):
            return .text(
                PluginMessageText(id: entity.id, text: entity.text, mimeType: entity.mimeType)
            )
        case .button(let entity):
            return .button(
                PluginMessageButton(id: entity.id, text: entity.text, postback: entity.postback, url: entity.url, displayInApp: entity.displayInApp)
            )
        case .file(let entity):
            return .file(
                PluginMessageFile(id: entity.id, fileName: entity.fileName, url: entity.url, mimeType: entity.mimeType)
            )
        case .title(let entity):
            return .title(
                PluginMessageTitle(id: entity.id, text: entity.text)
            )
        }
    }
    
    static func map(_ entity: PluginMessageSubElementType) -> PluginMessageSubElementDTOType {
        switch entity {
        case .text(let entity):
            return .text(
                PluginMessageTextDTO(id: entity.id, text: entity.text, mimeType: entity.mimeType)
            )
        case .button(let entity):
            return .button(
                PluginMessageButtonDTO(id: entity.id, text: entity.text, postback: entity.postback, url: entity.url, displayInApp: entity.displayInApp)
            )
        case .file(let entity):
            return .file(
                
                PluginMessageFileDTO(id: entity.id, fileName: entity.fileName, url: entity.url, mimeType: entity.mimeType))
        case .title(let entity):
            return .title(
                PluginMessageTitleDTO(id: entity.id, text: entity.text)
            )
        }
    }
}
