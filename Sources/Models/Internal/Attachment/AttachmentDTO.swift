import Foundation


/// Represents info about an uploaded attachment.
struct AttachmentDTO: Codable {
    
    /// The URL where the attachment can be found.
    let url: String

    /// A friendly name to display to the user.
    let friendlyName: String

    /// The MIME type relevant to the attachment type.
    let mimeType: String

    /// The name of the attachment file.
    let fileName: String
}
