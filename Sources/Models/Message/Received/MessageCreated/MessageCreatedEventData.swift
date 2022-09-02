import Foundation

public struct MessageCreatedEventData: Codable {
    public var brand: Brand
    public var channel: ChannelIdentifier
    public var `case`: Contact
    public var thread: Thread
    public var message: Message
}
