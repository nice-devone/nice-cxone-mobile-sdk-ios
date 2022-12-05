import Foundation


/// The different types of error that can be received from the WebSocket.
enum ErrorCode: String, Codable {
    
    case customerAuthorizationFailed = "ConsumerAuthorizationFailed"
    
    case customerReconnectFailed = "ConsumerReconnectionFailed"
    
    case tokenRefreshFailed = "TokenRefreshingFailed"
    
    case recoveringThreadFailed = "RecoveringThreadFailed"
    
    case inconsistentData = "InconsistentData"
}
