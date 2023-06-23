import Foundation


enum MessageRichLinkMapper {
    
    static func map(from entity: MessageRichLinkDTO) -> MessageRichLink {
        MessageRichLink(title: entity.title, url: entity.url, fileName: entity.fileName, fileUrl: entity.fileUrl, mimeType: entity.mimeType)
    }
    
    static func map(from entity: MessageRichLink) -> MessageRichLinkDTO {
        MessageRichLinkDTO(title: entity.title, url: entity.url, fileName: entity.fileName, fileUrl: entity.fileUrl, mimeType: entity.mimeType)
    }
}
