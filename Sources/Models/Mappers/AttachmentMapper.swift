import Foundation


enum AttachmentMapper {
    
    static func map(_ entity: Attachment) -> AttachmentDTO {
        AttachmentDTO(url: entity.url, friendlyName: entity.friendlyName, mimeType: entity.mimeType, fileName: entity.fileName)
    }
    
    static func map(_ entity: AttachmentDTO) -> Attachment {
        Attachment(url: entity.url, friendlyName: entity.friendlyName, mimeType: entity.mimeType, fileName: entity.fileName)
    }
}
