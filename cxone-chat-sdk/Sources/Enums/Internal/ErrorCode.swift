import Foundation

/// The different types of error that can be received from the WebSocket.
enum ErrorCode: String, Codable {
    
    case customerAuthorizationFailed = "CustomerAuthorizationFailed"
    
    case customerReconnectFailed = "CustomerReconnectionFailed"
    
    case tokenRefreshFailed = "TokenRefreshingFailed"
    
    case recoveringThreadFailed = "RecoveringThreadFailed"
    
    case inconsistentData = "InconsistentData"
}
