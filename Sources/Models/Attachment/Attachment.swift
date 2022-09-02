import Foundation

/// Represents info about an uploaded attachment.
public struct Attachment: Codable {
    /// The URL where the attachment can be found.
    public var url: String
    
    /// A friendly name to display to the user.
    public var friendlyName: String
    
    // Unused
//    public var id: String
//    public var securedPermanentUrl: String
//    public var previewUrl: String
}
