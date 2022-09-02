import Foundation

public struct ThreadRecoveredEventPostbackData: Codable {
    public var consumerContact: Contact
    public var messages: [Message]
    public var ownerAssignee: Agent?
    public var thread: ReceivedThreadData
    public var messagesScrollToken: String
}
