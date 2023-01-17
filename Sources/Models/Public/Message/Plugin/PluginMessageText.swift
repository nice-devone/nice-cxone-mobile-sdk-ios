import Foundation


/// A simple text subelement.
public struct PluginMessageText {
    
    // MARK: - Properties
    
    /// The unique identifier of the subelement.
    public let id: String
    
    /// The content of the sub element.
    public let text: String
    
    /// The MIME type relevant to the text.
    ///
    /// It can identify for example a markdown which indicates property `text` might contain special characters that need to be parsed.
    public let mimeType: String?
    
    
    // MARK: - Init
    
    /// - Parameters:
    ///   - id: The unique identifier of the subelement.
    ///   - text: The content of the sub element.
    ///   - mimeType: The MIME type relevant to the text.
    public init(id: String, text: String, mimeType: String?) {
        self.id = id
        self.text = text
        self.mimeType = mimeType
    }
}
