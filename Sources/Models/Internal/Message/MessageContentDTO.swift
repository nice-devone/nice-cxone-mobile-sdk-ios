import Foundation


/// Represents info abount a content in a message.
struct MessageContentDTO: Codable {
    
    // MARK: - Properties
    
    /// The type of the message content
    let type: MessageContentType
    
    /// The payload of the message
     let payload: MessagePayloadDTO
    
    /// The fallback text.
    let fallbackText: String
}
