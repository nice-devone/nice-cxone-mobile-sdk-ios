import Foundation


/// The direction that the message is being sent in regards to an agent.
public enum MessageDirection: String, Codable {
    
    /// Agent is receiving the message.
    case inbound
    
    /// Agent is sending the message.
    case outbound
}
