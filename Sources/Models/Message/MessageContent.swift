import Foundation

public struct MessageContent: Codable {
    public var type: MessageContentType
    public var payload: MessagePayload
    public var fallbackText: String
    public init(type: MessageContentType, payload: MessagePayload, fallbackText: String = "Unsupported message content") {
        self.type = type
        self.payload = payload
        self.fallbackText = fallbackText
    }
}
