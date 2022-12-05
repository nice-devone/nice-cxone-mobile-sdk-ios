import Foundation
import KeychainSwift


class ConnectionService: ConnectionProvider {
    
    // MARK: - Properties
    
    var channelConfiguration: ChannelConfiguration {
        get { ChannelConfigurationMapper.map(connectionContext.channelConfig) }
        set { connectionContext.channelConfig = ChannelConfigurationMapper.map(newValue) }
    }
    
    var socketService: SocketService
    var eventsService: EventsService
    
    var connectionContext: ConnectionContext {
        get { socketService.connectionContext }
        set {
            socketService.connectionContext = newValue
            eventsService.connectionContext = newValue
        }
    }
    
    
    // MARK: - Init
    
    init(socketService: SocketService, eventsService: EventsService) {
        self.socketService = socketService
        self.eventsService = eventsService
        
        self.connectionContext.channelConfig = .init(
            settings: .init(hasMultipleThreadsPerEndUser: false, isProactiveChatEnabled: false),
            isAuthorizationEnabled: false
        )
    }
    
    
    // MARK: - Implementation
    
    func getChannelConfiguration(environment: Environment, brandId: Int, channelId: String) async throws -> ChannelConfiguration {
        LogManager.trace("Getting channel configuration.")

        guard let url = URL(string: "\(environment.chatURL)/1.0/brand/\(brandId)/channel/\(channelId)") else {
            throw CXoneChatError.channelConfigFailure
        }

        return ChannelConfigurationMapper.map(try await getChannelConfiguration(url: url))
    }
    
    func getChannelConfiguration(chatURL: String, brandId: Int, channelId: String) async throws -> ChannelConfiguration {
        LogManager.trace("Getting channel configuration.")

        guard let url = URL(string: "\(chatURL)/1.0/brand/\(brandId)/channel/\(channelId)") else {
            throw CXoneChatError.channelConfigFailure
        }

        return ChannelConfigurationMapper.map(try await getChannelConfiguration(url: url))
    }
    
    func connect(environment: Environment, brandId: Int, channelId: String) async throws {
        LogManager.trace("connecting to the CXone service.")

        connectionContext.environment = environment
        
        try await connect(brandId: brandId, channelId: channelId)

        try checkForAuthorization()
    }
    
    func connect(chatURL: String, socketURL: String, brandId: Int, channelId: String) async throws {
        LogManager.trace("connecting to the CXone service.")

        connectionContext.environment = CustomEnvironment(chatURL: chatURL, socketURL: socketURL)

        try await connect(brandId: brandId, channelId: channelId)

        try checkForAuthorization()
    }
    
    func disconnect() {
        LogManager.trace("Disconnecting from the CXone service.")

        socketService.disconnect()
    }
    
    func ping() {
        LogManager.trace("Pinging the CXone chat server to ensure that a connection is established.")

        socketService.ping()
    }
    
    func executeTrigger(_ triggerId: UUID) throws {
        LogManager.trace("Executing trigger.")

        try socketService.checkForConnection()

        guard let visitorId = connectionContext.visitorId else {
            throw CXoneChatError.missingParameter("visitorId")
        }
        guard let customer = connectionContext.customer else {
            throw CXoneChatError.missingParameter("customer")
        }

        let payload = ExecuteTriggerEventPayloadDTO(
            eventType: .executeTrigger,
            brand: .init(id: connectionContext.brandId),
            channel: .init(id: connectionContext.channelId),
            consumerIdentity: customer,
            eventId: LowerCaseUUID(uuid: connectionContext.destinationId),
            visitorId: LowerCaseUUID(uuid: visitorId),
            triggerId: LowerCaseUUID(uuid: triggerId)
        )

        let data = try JSONEncoder().encode(ExecuteTriggerEventDTO(action: .chatWindowEvent, eventId: UUID(), payload: payload))

        socketService.send(message: data.utf8string)
    }
}


// MARK: - Private methods

private extension ConnectionService {
    
    func getChannelConfiguration(url: URL) async throws -> ChannelConfigurationDTO {
        let (data, _) = try await connectionContext.session.data(from: url)
        
        return try JSONDecoder().decode(ChannelConfigurationDTO.self, from: data)
    }
    
    func connect(brandId: Int, channelId: String) async throws {
        LogManager.trace("Connecting to the brand: \(brandId) and channel: \(channelId).")
        
        connectionContext.brandId = brandId
        connectionContext.channelId = channelId
        
        // Connect the WebSocket
        do {
            try connectToSocket()
        } catch {
            throw CXoneChatError.webSocketConnectionFailure
        }
        
        guard let url = URL(string: "\(connectionContext.environment.chatURL)/1.0/brand/\(brandId)/channel/\(channelId)") else {
            throw CXoneChatError.channelConfigFailure
        }
        
        connectionContext.channelConfig = try await getChannelConfiguration(url: url)
        
        LogManager.trace("Did get channel configuration: \(connectionContext.channelConfig)")
        
        connectionContext.destinationId = UUID()
        
        if connectionContext.visitorId == nil {
            connectionContext.visitorId = UUID()
        }
    }
    
    func connectToSocket() throws {
        LogManager.trace("Connecting to the socket.")
        
        let brandItem = URLQueryItem(name: "brand", value: connectionContext.brandId.description)
        let channelItem = URLQueryItem(name: "channelId", value: connectionContext.channelId)
        let customerIdItem = URLQueryItem(name: "customerId", value: connectionContext.customer?.idOnExternalPlatform)
        let vQItem = URLQueryItem(name: "v", value: "4.74")
        let eioQItem = URLQueryItem(name: "EIO", value: "3")
        let transportQItem = URLQueryItem(name: "transport", value: "polling")
        let tQItem = URLQueryItem(name: "t", value: "NlrXzTa")
        let socketEndpoint = SocketEndpointDTO(
            environment: connectionContext.environment,
            queryItems: [brandItem, channelItem, customerIdItem, vQItem, eioQItem, transportQItem, tQItem],
            method: .get
        )
        
        socketService.connect(socketURL: try socketEndpoint.urlRequest())
    }
    
    func checkForAuthorization() throws {
        LogManager.trace("Checking authorization.")
        
        if connectionContext.customer == nil {
            connectionContext.customer = .init(idOnExternalPlatform: UUID().uuidString, firstName: nil, lastName: nil)
            
            try authorizeCustomer()
        } else if connectionContext.channelConfig.isAuthorizationEnabled {
            try reconnectCustomer()
        } else {
            try authorizeCustomer()
        }
    }
    
    /// Authorizes a new customer to communicate through the WebSocket.
    func authorizeCustomer() throws {
        LogManager.trace("Authorizing customer.")
        
        let data = try eventsService.create(
            .authorizeCustomer,
            with: .authorizeCustomerData(
                .init(
                    authorizationCode: connectionContext.authorizationCode,
                    codeVerifier: connectionContext.codeVerifier
                )
            )
        )
        
        socketService.send(message: data.utf8string, shouldCheck: false)
    }
    
    /// Reconnects a returning customer to communicate through the WebSocket.
    func reconnectCustomer() throws {
        LogManager.trace("Reconnecting customer.")
        
        guard let token = socketService.accessToken?.token else {
            throw CXoneChatError.missingAccessToken
        }
        
        let data = try eventsService.create(.reconnectCustomer, with: .reconnectCustomerData(.init(token: token)))
        
        socketService.send(message: data.utf8string)
    }
}
