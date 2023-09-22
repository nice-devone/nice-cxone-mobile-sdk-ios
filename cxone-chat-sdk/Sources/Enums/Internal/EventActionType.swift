import Foundation

/// The different types of actions for an event.
enum EventActionType: String, Codable {
    
    /// The customer is registering for chat access.
    case register
    
    /// The customer is interacting with something in the chat window.
    case chatWindowEvent
    
    /// The customer is making an outbound action.
    case outbound
    
    /// The socket is sending a message to verify the connection.
    case heartbeat
}
