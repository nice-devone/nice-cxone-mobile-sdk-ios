import Foundation


/// Represents info abount a content in a message.
public struct MessageContent {
    
    // MARK: - Properties
    
    /// The type of the message content
    public let type: MessageContentType
    
    /// The payload of the message
    public let payload: MessagePayload
    
    /// The fallback text.
    public let fallbackText: String
}
