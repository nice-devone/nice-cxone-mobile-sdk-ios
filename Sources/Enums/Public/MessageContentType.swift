import Foundation


/// The different types of elements of message content.
public enum MessageContentType {
    
    /// A basic text message.
    case text(String)
    
    /// A rich message content type.
    case plugin(MessagePayload)
    
    /// An unknown content type.
    case unknown
}
