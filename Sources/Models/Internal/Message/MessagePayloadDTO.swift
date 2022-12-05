import Foundation


/// All info about a payload of a message.
struct MessagePayloadDTO: Codable {

    // MARK: - Properties

    /// The content of the payload.
    let text: String

    /// The set of message elements.
    let elements: [MessageElementDTO]
}
