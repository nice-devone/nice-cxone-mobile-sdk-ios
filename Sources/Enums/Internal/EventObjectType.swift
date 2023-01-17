import Foundation


/// The objects for which an event is applicable.
enum EventObjectType: String, Codable {
    
    /// The event is dealing with a contact.
    case contact = "Case"
    
    /// The event is dealing with a message.
    case message = "Message"
    
    /// The event is dealing with a sender action.
    case senderAction = "SenderAction"
    
    /// The event is dealing with a thread.
    case thread = "Thread"
    
    /// The event is dealing with a chat window.
    case chatWindow = "ChatWindow"

}
