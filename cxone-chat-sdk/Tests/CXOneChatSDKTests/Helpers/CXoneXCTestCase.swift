import XCTest
@testable import CXoneChatSDK

open class CXoneXCTestCase: XCTestCase {
    
    // MARK: - Properties
    
    let dateProvider = DateProviderMock()

    var configuration: URLSessionConfiguration = .default
    lazy var urlSession: URLSession = {
        configuration.protocolClasses = [URLProtocolMock.self]
        return URLSession(configuration: configuration)
    }()
    lazy var socketService = SocketServiceMock(session: urlSession)
    lazy var CXoneChat = CXoneChatSDK.CXoneChat(socketService: socketService)

    /// "chat_51eafb4e-8829-4efe-b58c-3bc9febf18c4"
    let channelId = "chat_51eafb4e-8829-4efe-b58c-3bc9febf18c4"
    /// "https://channels-de-na1.niceincontact.com/chat/1.0/brand/1386/channel"
    let chatURL = "https://channels-de-na1.niceincontact.com/chat"
    let channelURL = "https://channels-de-na1.niceincontact.com/chat/1.0/brand/1386/channel"
    /// 1386
    let brandId = 1386
    /// ""wss://chat-gateway-de-na1.niceincontact.com""
    let socketURL = "wss://chat-gateway-de-na1.niceincontact.com"
    
    lazy var configRequestHandler = accept(url(matches: ".*/\(channelId)$"), body: resource("ChannelConfiguration", type: "json"))

    // MARK: - Methods
    
    func setUpConnection() async throws {
        try await URLProtocolMock.with(handlers: configRequestHandler) {
            CXoneChat = CXoneChatSDK.CXoneChat(socketService: socketService)

            (CXoneChat.connection as? ConnectionService)?.connectionContext.destinationId = UUID()

            (CXoneChat.connection as? ConnectionService)?.connectionContext.channelConfig = ChannelConfigurationDTO(
                settings: ChannelSettingsDTO(hasMultipleThreadsPerEndUser: false, isProactiveChatEnabled: false),
                isAuthorizationEnabled: false,
                prechatSurvey: nil,
                contactCustomFieldDefinitions: [],
                customerCustomFieldDefinitions: []
            )

            try await CXoneChat.connection.connect(environment: .NA1, brandId: brandId, channelId: channelId)
        }
    }
}
