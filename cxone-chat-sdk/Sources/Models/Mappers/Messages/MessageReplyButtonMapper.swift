import Foundation

enum MessageReplyButtonMapper {
    
    static func map(from entity: MessageReplyButtonDTO) -> MessageReplyButton {
        MessageReplyButton(
            text: entity.text,
            postback: entity.postback,
            description: entity.description,
            iconName: entity.iconName,
            iconUrl: entity.iconUrl,
            iconMimeType: entity.iconMimeType
        )
    }
    
    static func map(from entity: MessageReplyButton) -> MessageReplyButtonDTO {
        MessageReplyButtonDTO(
            text: entity.text,
            postback: entity.postback,
            description: entity.description,
            iconName: entity.iconName,
            iconUrl: entity.iconUrl,
            iconMimeType: entity.iconMimeType
        )
    }
}
