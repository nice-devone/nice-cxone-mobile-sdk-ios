import Foundation


struct ThreadMetadataLoadedEventPostbackDataDTO: Decodable {
    
    /// The agent assigned to the thread.
    let ownerAssignee: AgentDTO?
    
    /// The last message posted in the chat thread.
    let lastMessage: MessageDTO
}
