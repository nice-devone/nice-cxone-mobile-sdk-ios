import Foundation


enum AttachmentMapper {
    
    static func map(_ entity: Attachment) -> AttachmentDTO {
        .init(url: entity.url, friendlyName: entity.friendlyName, mimeType: entity.mimeType, fileName: entity.fileName)
    }
    
    static func map(_ entity: AttachmentDTO) -> Attachment {
        .init(url: entity.url, friendlyName: entity.friendlyName, mimeType: entity.mimeType, fileName: entity.fileName)
    }
}
