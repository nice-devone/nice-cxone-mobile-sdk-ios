import Foundation


/// Data for the ContactInboxAssigneeChanged event.
struct ContactInboxAssigneeChangedDataDTO: Codable {
    
    /// The brand for which this change applies.
    let brand: BrandDTO

    /// The channel for which this change applies.
    let channel: ChannelIdentifierDTO

    /// The contact for which this change applies.
    let `case`: ContactDTO

    /// The agent that is now assigned to this contact.
    let inboxAssignee: AgentDTO

    /// The agent that was previously assigned to the contact, if any.
    let previousInboxAssignee: AgentDTO?
}
