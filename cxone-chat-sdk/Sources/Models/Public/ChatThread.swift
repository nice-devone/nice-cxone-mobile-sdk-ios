import Foundation

/// All information about a chat thread as well as the messages for the thread.
public struct ChatThread {
    
    /// The unique id of the thread. Refers to the `idOnExternalPlatform`.
    public let id: UUID
    
    /// The name given to the thread (for multi-thread channels only).
    public var name: String?
    
    /// The list of messages on the thread.
    public var messages = [Message]()
    
    /// The agent assigned in the thread.
    public var assignedAgent: Agent?
    
    /// Whether more messages can be added to the thread (not archived) or otherwise (archived).
    public var canAddMoreMessages = true
    
    /// Id of the contact in this thread
    var contactId: String?
    
    /// The token for the scroll position used to load more messages.
    public var scrollToken: String = ""
    
    /// Whether there are more messages to load in the thread.
    public var hasMoreMessagesToLoad: Bool {
        !scrollToken.isEmpty
    }
}
