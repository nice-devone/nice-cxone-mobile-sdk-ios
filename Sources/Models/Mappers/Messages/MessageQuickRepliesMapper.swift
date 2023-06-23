import Foundation


enum MessageQuickRepliesMapper {
    
    static func map(from entity: MessageQuickRepliesDTO) -> MessageQuickReplies {
        MessageQuickReplies(title: entity.title, buttons: entity.buttons.map(MessageReplyButtonMapper.map))
    }
    
    static func map(from entity: MessageQuickReplies) -> MessageQuickRepliesDTO {
        MessageQuickRepliesDTO(title: entity.title, buttons: entity.buttons.map(MessageReplyButtonMapper.map))
    }
}
