import Foundation


enum AttachmentUploadMapper {
    
    static func map(_ entity: AttachmentUploadDTO) -> ContentDescriptor {
        ContentDescriptor(
            data: entity.attachmentData,
            mimeType: entity.mimeType,
            fileName: entity.fileName,
            friendlyName: entity.friendlyName
        )
    }
}
