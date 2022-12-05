import Foundation


/// Represents info about an attachment data to be uploaded.
public struct AttachmentUpload {
    
    // MARK: - Properties

    /// The actual data of the attachment.
    public let data: Data

    /// The MIME type relevant to the attachment type.
    public let mimeType: String

    /// The name of the attachment file.
    public let fileName: String
    
    
    // MARK: - Init
    
    /// - Parameters:
    ///    - data: The actual data of the attachment.
    ///    - mimeType: The MIME type relevant to the attachment type.
    ///    - fileName: The name of the attachment file.
    public init(data: Data, mimeType: String, fileName: String) {
        self.data = data
        self.mimeType = mimeType
        self.fileName = fileName
    }
}
