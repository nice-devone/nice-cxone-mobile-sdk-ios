import Foundation


/// Response given when an attachment is successfully uploaded.
struct AttachmentUploadSuccessResponseDTO: Decodable {
    
    /// The URL where the uploaded attachment can be found.
	let fileUrl: String
}
