import Foundation


/// Represents info about an attachment data to be uploaded.
struct AttachmentUploadDTO {

    /// The actual data of the attachment.
    let attachmentData: Data

    /// The MIME type relevant to the attachment type.
    let mimeType: String

    /// The name of the attachment file.
    let fileName: String
}
