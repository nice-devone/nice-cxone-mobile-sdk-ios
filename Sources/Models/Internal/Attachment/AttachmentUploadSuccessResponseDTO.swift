import Foundation


/// Response given when an attachment is successfully uploaded.
struct AttachmentUploadSuccessResponseDTO: Codable {
    
    /// The URL where the uploaded attachment can be found.
	let fileUrl: String
}
