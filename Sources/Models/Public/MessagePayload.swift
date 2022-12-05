import Foundation


/// All info about a payload of a message.
public struct MessagePayload {

    /// The content of the payload.
    public let text: String

    /// The set of message elements.
    public let elements: [MessageElement]
}
