import Foundation
@testable import CXoneChatSDK
import KeychainSwift


class SocketServiceMock: SocketService {
    
    // MARK: - Properties
    
    var pingNumber = 0
    var messageSend = 0
    var messageSent: ((String) -> Void)?
    
    var socket: URLSessionWebSocketTaskProtocol?
    var internalAccessToken: AccessTokenDTO?
    var internalAccessTokenGetterCount = 0
    var internalAccessTokenSetterCount = 0
    
    override var accessToken: AccessTokenDTO? {
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

    
    // MARK: - Init
    
    init(session: URLSession = .shared) {
        super.init(keychainSwift: KeychainSwiftMock(), session: session)
        
        self.connectionContext = ConnectionCotextMock()
    }
    
    
    // MARK: - Methods
    
    override func ping() {
        pingNumber += 1
    }
    
    override func send(message: String, shouldCheck: Bool = true) {
        messageSend += 1
        messageSent?(message)
    }
}
