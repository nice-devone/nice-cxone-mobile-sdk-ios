import Foundation

/// All info about a payload of a message.
struct MessagePayloadDTO: Equatable {
    
    /// The content of the payload.
    let text: String
    
    /// The postback  of the payload.
    let postback: String?
}
