import Foundation

/// All information about a chat thread as well as the messages for the thread.
public struct ChatThread {
    
    /// The internal id of the thread.
	internal var id: String?
    
    /// The unique id of the thread.
	public var idOnExternalPlatform: UUID
    
    /// The name given to the thread (for multi-thread channels only).
    public var threadName: String?
    
    /// The list of messages on the thread.
	public var messages: [Message] = []
    
    /// The agent assigned in the thread.
	public var threadAgent: Agent? = nil
    
    /// Whether more messages can be added to the thread (not archived) or otherwise (archived).
    public var canAddMoreMessages = true
    
    /// The token for the scroll position used to load more messages.
    internal var scrollToken: String = ""
    
    /// Whether there are more messages to load in the thread.
    public var hasMoreMessagesToLoad: Bool {
        return scrollToken.isEmpty == false
    }
}
