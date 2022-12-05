import XCTest
@testable import CXoneChatSDK


open class CXoneXCTestCase: XCTestCase {
    
    // MARK: - Properties
    
    lazy var CXoneChat = CXoneChatSDK.CXoneChat(socketService: socketService)
    lazy var socketService = SocketServiceMock(session: urlSession)
    
    var configuration: URLSessionConfiguration = .default
    var urlSession: URLSession = .shared
    
    /// "chat_51eafb4e-8829-4efe-b58c-3bc9febf18c4"
    let channelId = "chat_51eafb4e-8829-4efe-b58c-3bc9febf18c4"
    /// "https://channels-de-na1.niceincontact.com/chat/1.0/brand/1386/channel"
    let chatURL = "https://channels-de-na1.niceincontact.com/chat"
    let channelURL = "https://channels-de-na1.niceincontact.com/chat/1.0/brand/1386/channel"
    /// 1386
    let brandId = 1386
    /// ""wss://chat-gateway-de-na1.niceincontact.com""
    let socketURL = "wss://chat-gateway-de-na1.niceincontact.com"
    
    
    // MARK: - Methods
    
    func setUpConnection() async throws {
        configuration.protocolClasses = [URLProtocolMock.self]
        urlSession = URLSession(configuration: configuration)
        
        URLProtocolMock.requestHandler = { _ in
            guard let url = URL(string: "\(self.channelURL)/\(self.channelId)/attachment"),
                  let response = HTTPURLResponse(url: url, statusCode: 200, httpVersion: nil, headerFields: nil)
            else {
                XCTFail("Could not init URL.")
                throw CXoneChatError.invalidRequest
            }
            
            return (response, Data())
        }
        
        CXoneChat = CXoneChatSDK.CXoneChat(socketService: socketService)
        
        (CXoneChat.connection as? ConnectionService)?.connectionContext.destinationId = UUID()
        
        (CXoneChat.connection as? ConnectionService)?.connectionContext.channelConfig = ChannelConfigurationDTO(
            settings: ChannelSettingsDTO(hasMultipleThreadsPerEndUser: false, isProactiveChatEnabled: false),
            isAuthorizationEnabled: false
        )
        
        try await CXoneChat.connection.connect(environment: .NA1, brandId: brandId, channelId: channelId)
    }
}
