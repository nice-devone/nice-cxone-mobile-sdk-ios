import Foundation

/// The different types of error that can be received from the WebSocket.
internal enum ErrorCode: String, Codable {
    
    case customerAuthorizationFailed = "ConsumerAuthorizationFailed"
    
    case customerReconnectFailed = "ConsumerReconnectionFailed"
    
    case tokenRefreshFailed = "TokenRefreshingFailed"

    case recoveringThreadFailed = "RecoveringThreadFailed"
        
    // TODO: Re-enable once live chat is supported
//    case recoveringLiveChatFailed = "RecoveringLivechatFailed"
    
}
