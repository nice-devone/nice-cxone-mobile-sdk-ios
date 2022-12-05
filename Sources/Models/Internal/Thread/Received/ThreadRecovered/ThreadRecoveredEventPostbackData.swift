import Foundation


/// Represents data about a thread recovered event postback.
struct ThreadRecoveredEventPostbackDataDTO: Codable {
    
    /// The info about a contact (case).
    let consumerContact: ContactDTO

    /// The list of messages on the thread.
    let messages: [MessageDTO]

    /// The info about an agent.
    let ownerAssignee: AgentDTO?

    /// The info abount about received thread.
    let thread: ReceivedThreadDataDTO

    /// The scroll token of the messages.
    let messagesScrollToken: String
}
