import Foundation


enum MessageListPickerMapper {
    
    static func map(from entity: MessageListPickerDTO) -> MessageListPicker {
        MessageListPicker(title: entity.title, text: entity.text, elements: entity.elements.map(MessageSubElementMapper.map))
    }
    
    static func map(from entity: MessageListPicker) -> MessageListPickerDTO {
        MessageListPickerDTO(title: entity.title, text: entity.text, elements: entity.elements.map(MessageSubElementMapper.map))
    }
}
