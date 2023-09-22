import Foundation

/// Represents info about an attachment data to be uploaded.
public struct ContentDescriptor {
    
    // MARK: - Properties

    /// The actual data of the attachment.
    public let data: ContentDescriptorSource

    /// The MIME type relevant to the attachment type.
    public let mimeType: String

    /// The name of the attachment file.
    public let fileName: String

    /// The friendly (original) name of the file
    public let friendlyName: String
    
    // MARK: - Init
    
    /// - Parameters:
    ///    - data: The actual data of the attachment.
    ///    - mimeType: The MIME type relevant to the attachment type.
    ///    - fileName: The obscured name of the attachment file sent to the server.
    ///    - friendlyName: The friendly (original) name of the attachment file
    public init(data: Data, mimeType: String, fileName: String, friendlyName: String) {
        self.data = ContentDescriptorSource.bytes(data)
        self.mimeType = mimeType
        self.fileName = fileName
        self.friendlyName = friendlyName
    }

    /// - Parameters:
    ///    - data: The actual data of the attachment.
    ///    - mimeType: The MIME type relevant to the attachment type.
    ///    - fileName: The obscured name of the attachment file sent to the server.
    ///    - friendlyName: The friendly (original) name of the attachment file
    public init(url: URL, mimeType: String, fileName: String, friendlyName: String) {
        self.data = .url(url)
        self.mimeType = mimeType
        self.fileName = fileName
        self.friendlyName = friendlyName
    }
}
