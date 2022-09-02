
import Foundation
public struct AttachmentUpload {
    var attachmentData: Data
    var mimeType: String
    var fileName: String
    
    public init(attachmentData: Data, mimeType: String, fileName: String) {
        self.attachmentData = attachmentData
        self.mimeType = mimeType
        self.fileName = fileName
    }
}
