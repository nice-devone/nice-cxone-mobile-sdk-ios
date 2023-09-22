import Foundation

/// The direction that the message is being sent in regards to an agent.
public enum MessageDirection {
    
    /// Agent is receiving the message (inbound message).
    case toAgent
    
    /// Agent is sending the message (outbound message).
    case toClient
}
