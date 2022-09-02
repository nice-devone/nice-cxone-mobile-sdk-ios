import Foundation

/// Information about the sender of a chat message.
public struct SenderInfo {
    
    /// The unique id for the sender (agent or customer). Represents the idOnExternalPlatform for a customer and the id for the agent.
    public let id: String
    
    /// The first name of the sender.
    public let firstName: String
    
    /// The last name of the sender.
    public let lastName: String
    
    /// The full name of the sender.
    public var fullName: String {
        return "\(firstName) \(lastName)"
    }
    
    /// Whether the sender is an agent or not.
    public let isAgent: Bool
    
    internal init(message: Message) {
        isAgent = message.direction == .outbound
        if isAgent {
            firstName = message.authorUser?.firstName ?? "Automated"
            lastName = message.authorUser?.surname ?? "Agent"
            self.id = String(message.authorUser?.id ?? 0)
        } else {
            firstName = message.authorEndUserIdentity?.firstName ?? "Unknown"
            lastName = message.authorEndUserIdentity?.lastName ?? "Customer"
            id = String(message.authorEndUserIdentity?.idOnExternalPlatform ?? UUID().uuidString)
        }
    }
}
