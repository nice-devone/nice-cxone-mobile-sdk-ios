
import Foundation
@testable import CXOneChatSDK
class SocketServiceMock: SocketService {
    var pingNumber = 0
    
    var messageSend = 0
    
    var messageSent: ((String) -> Void)?
    
    override var connected: Bool {
        return conectionStatus
    }
    var conectionStatus = true
    
    override func ping() {
        pingNumber += 1
    }
    override func send(message: String, shouldCheck: Bool = true) {
        messageSend += 1
        messageSent?(message)
    }
    var socket: URLSessionWebSocketTaskProtocol?
    var internalAccessToken: AccessToken?
    var internalAccessTokenGetterCount = 0
    var internalAccessTokenSetterCount = 0
    
    override var accessToken: AccessToken? {
        get {
            internalAccessTokenGetterCount += 1
            return internalAccessToken            
        }
        set {
            internalAccessToken = newValue
            if newValue != nil {
                internalAccessTokenSetterCount += 1
            }
        }
    }
}
