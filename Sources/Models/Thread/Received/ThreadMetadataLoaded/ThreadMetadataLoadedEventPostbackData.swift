import Foundation

struct ThreadMetadataLoadedEventPostbackData: Codable {
    /// The agent assigned to the thread.
    let ownerAssignee: Agent?
    
    /// The last message posted in the chat thread.
    let lastMessage: Message
}
