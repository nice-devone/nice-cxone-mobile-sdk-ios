import Foundation

/// A file subelement.
public struct PluginMessageFile {
    
    // MARK: - Properties
    
    /// The unique identifier of the subelement.
    public let id: String
    
    /// The name of the attachment file.
    public let fileName: String
    
    /// The URL where the attachment can be found.
    public let url: URL
    
    /// The MIME type relevant to the attachment type.
    public let mimeType: String
    
    // MARK: - Init
    
    /// - Parameters:
    ///   - id: The unique identifier of the subelement.
    ///   - fileName: The name of the attachment file.
    ///   - url: The URL where the attachment can be found.
    ///   - mimeType: The MIME type relevant to the attachment type.
    public init(id: String, fileName: String, url: URL, mimeType: String) {
        self.id = id
        self.fileName = fileName
        self.url = url
        self.mimeType = mimeType
    }
}
