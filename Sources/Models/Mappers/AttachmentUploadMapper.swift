import Foundation


enum AttachmentUploadMapper {
    
    static func map(_ entity: AttachmentUploadDTO) -> AttachmentUpload {
        .init(data: entity.attachmentData, mimeType: entity.mimeType, fileName: entity.fileName)
    }
}
