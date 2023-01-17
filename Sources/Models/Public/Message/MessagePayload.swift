import Foundation


/// All info about a payload of a message.
public struct MessagePayload {

    /// The content of the payload.
    public let text: String?
    
    /// The postaback of the payload.
    public let postback: String?

    /// The type of message payload content
    public let element: PluginMessageType
}
