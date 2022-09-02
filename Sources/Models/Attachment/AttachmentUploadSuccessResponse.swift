import Foundation

/// Response given when an attachment is successfully uploaded.
public struct AttachmentUploadSuccessResponse: Codable {
    /// The URL where the uploaded attachment can be found.
	public var fileUrl: String
}
