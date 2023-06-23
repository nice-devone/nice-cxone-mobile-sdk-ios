import Foundation


/// It is a URL link with an image preview and a defined title.
///
/// The customer is able to click on it to be forwarded to the particular page.
public struct MessageRichLink {
    
    /// Title of the Rich Link in the conversation
    public let title: String
    
    /// URL link to the address we are linking to
    public let url: URL
    
    /// The image name that will be displayed in the rich link​ (256 KiB)
    public let fileName: String
    
    /// The image URL that will be displayed in the rich link​ (256 KiB)
    public let fileUrl: URL
    
    /// /// The image MIME type that will be displayed in the rich link​ (256 KiB)
    public let mimeType: String
}
