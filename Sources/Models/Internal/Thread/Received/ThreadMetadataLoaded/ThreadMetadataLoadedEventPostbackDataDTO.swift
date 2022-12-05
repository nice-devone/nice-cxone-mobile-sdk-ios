import Foundation


struct ThreadMetadataLoadedEventPostbackDataDTO: Codable {
    
    /// The agent assigned to the thread.
    let ownerAssignee: AgentDTO?
    
    /// The last message posted in the chat thread.
    let lastMessage: MessageDTO
}
