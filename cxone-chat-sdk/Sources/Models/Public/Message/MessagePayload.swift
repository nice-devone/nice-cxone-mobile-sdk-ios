import Foundation

/// All info about a payload of a message.
public struct MessagePayload {

    /// The content of the payload.
    public let text: String
    
    /// The postback  of the payload.
    public let postback: String?
}
