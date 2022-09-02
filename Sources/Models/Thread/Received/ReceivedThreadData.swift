import Foundation

public struct ReceivedThreadData: Codable {
    internal var id: String
    public var idOnExternalPlatform: UUID
    public var channelId: String
    public var threadName: String
    public var createdAt: String // TODO: Change type to Date
    public var updatedAt: String // TODO: Change type to Date
    public var canAddMoreMessages: Bool
}
