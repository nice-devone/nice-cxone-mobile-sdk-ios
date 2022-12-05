import Foundation


enum MessageElementMapper {
    
    static func map(_ entity: MessageElement) -> MessageElementDTO {
        .init(
            id: entity.id,
            type: entity.type,
            text: entity.text,
            postback: entity.postback,
            url: entity.url,
            fileName: entity.fileName,
            mimeType: entity.mimeType,
            elements: entity.elements?.map(MessageElementMapper.map)
        )
    }
    
    static func map(_ entity: MessageElementDTO) -> MessageElement {
        .init(
            id: entity.id,
            type: entity.type,
            text: entity.text,
            postback: entity.postback,
            url: entity.url,
            fileName: entity.fileName,
            mimeType: entity.mimeType,
            elements: entity.elements?.map(MessageElementMapper.map)
        )
    }
}
