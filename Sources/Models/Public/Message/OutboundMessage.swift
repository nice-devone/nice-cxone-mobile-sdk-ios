import Foundation


/// Represents outbound message which is send to an agent.
public struct OutboundMessage {
    
    // MARK: - Properties
    
    /// The text of the message.
    public let text: String
    
    /// The list of attachments. May contain single attachment.
    public let attachments: [ContentDescriptor]
    
    /// The postback used within rich content messages.
    ///
    /// This value must be provided when sending answer prompt with a rich content type defined in ``MessageContentType``.
    public let postback: String?
    
    
    // MARK: - Init
    
    /// - Parameters:
    ///   - text: The text of the message.
    ///   - attachments: The list of attachments. May contain single attachment.
    ///   - postback: The postback used within rich content messages.
    public init(text: String, attachments: [ContentDescriptor] = [], postback: String? = nil) {
        self.text = text
        self.attachments = attachments
        self.postback = postback
    }
}
