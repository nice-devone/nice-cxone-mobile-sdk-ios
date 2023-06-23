import Foundation


/// All information about a chat thread as well as the messages for the thread.
struct ChatThreadDTO {
    
    /// The unique id of the thread.
    let idOnExternalPlatform: UUID
    
    /// The name given to the thread (for multi-thread channels only).
    let threadName: String?
    
    /// The list of messages on the thread.
    var messages: [MessageDTO]
    
    /// The agent assigned in the thread.
    let threadAgent: AgentDTO?
    
    /// Whether more messages can be added to the thread (not archived) or otherwise (archived).
    let canAddMoreMessages: Bool
    
    /// Id of the contact in this thread
    let contactId: String?
    
    /// The token for the scroll position used to load more messages.
    let scrollToken: String
    
    /// Whether there are more messages to load in the thread.
    var hasMoreMessagesToLoad: Bool {
        !scrollToken.isEmpty
    }
}
