import Foundation


enum MessageDirectionDTOType: String, Codable {
    
    /// Agent is receiving the message.
    case inbound
    
    /// Agent is sending the message.
    case outbound
}
