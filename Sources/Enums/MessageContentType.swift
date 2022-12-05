import Foundation


/// The different types of message content that can be sent or received.
public enum MessageContentType: String, Codable {
    
    /// The message is only sending text.
    case text = "TEXT"

    /// The message is sending a plugin to be displayed.
    case plugin = "PLUGIN"
    
    /// Some unknown message type.
    case unknown
    
    
    // MARK: - Init
    
    /// Allows for decoding with an unknown string.
    public init(from decoder: Decoder) throws {
        self = try MessageContentType(rawValue: decoder.singleValueContainer().decode(RawValue.self)) ?? .unknown
    }
}
