
import Foundation

/// Data for the ContactInboxAssigneeChanged event.
struct ContactInboxAssigneeChangedData: Codable {
    
    /// The brand for which this change applies.
    var brand: Brand
    
    /// The channel for which this change applies.
    var channel: ChannelIdentifier
    
    /// The contact for which this change applies.
    var `case`: Contact
    
    /// The agent that is now assigned to this contact.
    var inboxAssignee: Agent
    
    /// The agent that was previously assigned to the contact, if any.
    var previousInboxAssignee: Agent?
}
