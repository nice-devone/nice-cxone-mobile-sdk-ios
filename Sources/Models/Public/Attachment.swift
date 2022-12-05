import Foundation


/// Represents info about an uploaded attachment.
public struct Attachment {
    
    /// The URL where the attachment can be found.
    public let url: String

    /// A friendly name to display to the user.
    public let friendlyName: String

    /// The MIME type relevant to the attachment type.
    public let mimeType: String

    /// The name of the attachment file.
    public let fileName: String
}
