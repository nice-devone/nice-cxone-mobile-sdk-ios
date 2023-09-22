import Foundation
import KeychainSwift

class ConnectionService: ConnectionProvider {
    
    // MARK: - Properties
    
    var socketService: SocketService
    var eventsService: EventsService
    
    var connectionContext: ConnectionContext {
        get { socketService.connectionContext }
        set {
            socketService.connectionContext = newValue
            eventsService.connectionContext = newValue
        }
    }
    
    // MARK: - Protocol Properties
    
    var channelConfiguration: ChannelConfiguration {
        get { ChannelConfigurationMapper.map(connectionContext.channelConfig) }
        set { connectionContext.channelConfig = ChannelConfigurationMapper.map(newValue) }
    }
    
    // MARK: - Init
    
    init(socketService: SocketService, eventsService: EventsService) {
        self.socketService = socketService
        self.eventsService = eventsService
        
        self.connectionContext.channelConfig = ChannelConfigurationDTO(
            settings: ChannelSettingsDTO(hasMultipleThreadsPerEndUser: false, isProactiveChatEnabled: false),
            isAuthorizationEnabled: false,
            prechatSurvey: nil,
            contactCustomFieldDefinitions: [],
            customerCustomFieldDefinitions: []
        )
    }
    
    // MARK: - Implementation
    
    /// - Throws: ``CXoneChatError/channelConfigFailure`` if provided parameters do not create a valid URL.
    /// - Throws: ``DecodingError.dataCorrupted`` an indication that the data is corrupted or otherwise invalid.
    /// - Throws: ``DecodingError.typeMismatch`` if the encountered stored value is not a JSON object or otherwise cannot be converted to the required type.
    /// - Throws: ``DecodingError.keyNotFound`` if the response does not have an entry for the given key.
    /// - Throws: ``DecodingError.valueNotFound`` if a response has a null value for the given key.
    func getChannelConfiguration(environment: Environment, brandId: Int, channelId: String) async throws -> ChannelConfiguration {
        LogManager.trace("Getting channel configuration.")

        guard brandId > 0, !channelId.isEmpty, let url = URL(string: "\(environment.chatURL)/1.0/brand/\(brandId)/channel/\(channelId)") else {
            throw CXoneChatError.channelConfigFailure
        }

        return ChannelConfigurationMapper.map(try await getChannelConfiguration(url: url))
    }
    
    /// - Throws: ``CXoneChatError/channelConfigFailure`` if provided parameters do not create a valid URL.
    /// - Throws: ``DecodingError.dataCorrupted`` an indication that the data is corrupted or otherwise invalid.
    /// - Throws: ``DecodingError.typeMismatch`` if the encountered stored value is not a JSON object or otherwise cannot be converted to the required type.
    /// - Throws: ``DecodingError.keyNotFound`` if the response does not have an entry for the given key.
    /// - Throws: ``DecodingError.valueNotFound`` if a response has a null value for the given key.
    func getChannelConfiguration(chatURL: String, brandId: Int, channelId: String) async throws -> ChannelConfiguration {
        LogManager.trace("Getting channel configuration.")

        guard brandId > 0, !channelId.isEmpty, let url = URL(string: "\(chatURL)/1.0/brand/\(brandId)/channel/\(channelId)") else {
            throw CXoneChatError.channelConfigFailure
        }

        return ChannelConfigurationMapper.map(try await getChannelConfiguration(url: url))
    }
    
    /// - Throws: ``CXoneChatError/channelConfigFailure`` if the SDK could not prepare URL for URLRequest
    /// - Throws: ``CXoneChatError/webSocketConnectionFailure`` if the WebSocket refused to connect.
    /// - Throws: ``CXoneChatError/missingParameter(_:)`` if connection`url` is not in correct format.
    /// - Throws: ``CXoneChatError/missingAccessToken`` if the customer was successfully authorized, but an access token wasn’t returned.
    /// - Throws: ``DecodingError.dataCorrupted`` an indication that the data is corrupted or otherwise invalid.
    /// - Throws: ``DecodingError.typeMismatch`` if the encountered stored value is not a JSON object or otherwise cannot be converted to the required type.
    /// - Throws: ``DecodingError.keyNotFound`` if the response does not have an entry for the given key.
    /// - Throws: ``DecodingError.valueNotFound`` if a response has a null value for the given key.
    /// - Throws: ``EncodingError.invalidValue(_:_:)`` if the given value is invalid in the current context for this format.
    /// - Throws: ``URLError.badServerResponse`` if the URL Loading system received bad data from the server.
    /// - Throws: ``NSError`` object that indicates why the request failed
    func connect(environment: Environment, brandId: Int, channelId: String) async throws {
        LogManager.trace("connecting to the CXone service.")

        connectionContext.environment = environment
        
        try await connect(brandId: brandId, channelId: channelId)

        try await checkForAuthorization()
    }
    
    /// - Throws: ``CXoneChatError/channelConfigFailure`` if the SDK could not prepare URL for URLRequest
    /// - Throws: ``CXoneChatError/webSocketConnectionFailure`` if the WebSocket refused to connect.
    /// - Throws: ``CXoneChatError/missingParameter(_:)`` if connection`url` is not in correct format.
    /// - Throws: ``CXoneChatError/missingAccessToken`` if the customer was successfully authorized, but an access token wasn’t returned.
    /// - Throws: ``DecodingError.dataCorrupted`` an indication that the data is corrupted or otherwise invalid.
    /// - Throws: ``DecodingError.typeMismatch`` if the encountered stored value is not a JSON object or otherwise cannot be converted to the required type.
    /// - Throws: ``DecodingError.keyNotFound`` if the response does not have an entry for the given key.
    /// - Throws: ``DecodingError.valueNotFound`` if a response has a null value for the given key.
    /// - Throws: ``EncodingError.invalidValue(_:_:)`` if the given value is invalid in the current context for this format.
    /// - Throws: ``URLError.badServerResponse`` if the URL Loading system received bad data from the server.
    /// - Throws: ``NSError`` object that indicates why the request failed
    func connect(chatURL: String, socketURL: String, brandId: Int, channelId: String) async throws {
        LogManager.trace("connecting to the CXone service.")

        connectionContext.environment = CustomEnvironment(chatURL: chatURL, socketURL: socketURL)

        try await connect(brandId: brandId, channelId: channelId)

        try await checkForAuthorization()
    }

    func disconnect() {
        LogManager.trace("Disconnecting from the CXone service.")

        socketService.disconnect()
    }
    
    func ping() {
        LogManager.trace("Pinging the CXone chat server to ensure that a connection is established.")

        socketService.ping()
    }
    
    /// - Throws: ``CXoneChatError/notConnected`` if an attempt was made to use a method without connecting first.
    ///     Make sure you call the `connect` method first.
    /// - Throws: ``CXoneChatError/customerVisitorAssociationFailure`` if the customer could not be associated with a visitor.
    /// - Throws: ``CXoneChatError/customerAssociationFailure`` The SDK instance could not get customer identity possibly because it may not have been set.
    /// - Throws: ``EncodingError.invalidValue(_:_:)`` if the given value is invalid in the current context for this format.
    func executeTrigger(_ triggerId: UUID) throws {
        LogManager.trace("Executing trigger.")

        try socketService.checkForConnection()

        guard let visitorId = connectionContext.visitorId else {
            throw CXoneChatError.customerVisitorAssociationFailure
        }
        guard let customer = connectionContext.customer else {
            throw CXoneChatError.customerAssociationFailure
        }

        let payload = ExecuteTriggerEventPayloadDTO(
            eventType: .executeTrigger,
            brand: BrandDTO(id: connectionContext.brandId),
            channel: ChannelIdentifierDTO(id: connectionContext.channelId),
            customerIdentity: customer,
            eventId: LowerCaseUUID(uuid: connectionContext.destinationId),
            visitorId: LowerCaseUUID(uuid: visitorId),
            triggerId: LowerCaseUUID(uuid: triggerId)
        )

        let data = try JSONEncoder().encode(ExecuteTriggerEventDTO(action: .chatWindowEvent, eventId: UUID(), payload: payload))

        socketService.send(message: data.utf8string)
    }
    
    // MARK: - Internal Methods
    
    func signOut() {
        LogManager.trace("Signing out an user.")
        
        socketService.disconnect()
        
        connectionContext.clear()
    }
}

// MARK: - Private methods

private extension ConnectionService {
    
    /// - Throws: ``DecodingError.dataCorrupted`` an indication that the data is corrupted or otherwise invalid.
    /// - Throws: ``DecodingError.typeMismatch`` if the encountered stored value is not a JSON object or otherwise cannot be converted to the required type.
    /// - Throws: ``DecodingError.keyNotFound`` if the response does not have an entry for the given key.
    /// - Throws: ``DecodingError.valueNotFound`` if a response has a null value for the given key.
    /// - Throws: ``URLError.badServerResponse`` if the URL Loading system received bad data from the server.
    /// - Throws: ``NSError`` object that indicates why the request failed
    func getChannelConfiguration(url: URL) async throws -> ChannelConfigurationDTO {
        try await Task
            .retrying {
                let (data, _) = try await self.connectionContext.session.data(from: url)
                
                return try JSONDecoder().decode(ChannelConfigurationDTO.self, from: data)
            }
            .value
    }

    /// - Throws: ``CXoneChatError/webSocketConnectionFailure`` if the WebSocket refused to connect.
    /// - Throws: ``CXoneChatError/missingParameter(_:)`` if connection`url` is not in correct format.
    /// - Throws: ``DecodingError.dataCorrupted`` an indication that the data is corrupted or otherwise invalid.
    /// - Throws: ``URLError.badServerResponse`` if the URL Loading system received bad data from the server.
    func connect(brandId: Int, channelId: String) async throws {
        LogManager.trace("Connecting to the brand: \(brandId) and channel: \(channelId).")
        
        guard brandId > 0, !channelId.isEmpty, let url = URL(string: "\(connectionContext.environment.chatURL)/1.0/brand/\(brandId)/channel/\(channelId)") else {
            throw CXoneChatError.missingParameter("url")
        }
        
        connectionContext.brandId = brandId
        connectionContext.channelId = channelId
        
        // Connect the WebSocket
        do {
            try connectToSocket()
        } catch {
            error.logError()
            
            throw CXoneChatError.webSocketConnectionFailure
        }
        
        connectionContext.channelConfig = try await getChannelConfiguration(url: url)
        
        LogManager.trace("Did get channel configuration: \(connectionContext.channelConfig)")
        
        connectionContext.destinationId = UUID()
        
        if connectionContext.visitorId == nil {
            let visitorId = UUID()
            connectionContext.visitorId = visitorId
            
            if let customerId = connectionContext.customer?.idOnExternalPlatform {
                try await createOrUpdateVisitor(visitorId: visitorId, customerId: customerId)
            }
        }
    }
    
    /// - Throws: ``CXoneChatError/invalidRequest`` if connection `url` is not set properly.
    func connectToSocket() throws {
        LogManager.trace("Connecting to the socket.")
        
        let socketEndpoint = SocketEndpointDTO(
            environment: connectionContext.environment,
            queryItems: [
                URLQueryItem(name: "brand", value: connectionContext.brandId.description),
                URLQueryItem(name: "channelId", value: connectionContext.channelId),
                URLQueryItem(name: "applicationType", value: "native"),
                URLQueryItem(name: "os", value: "iOS"),
                URLQueryItem(name: "clientVersion", value: CXoneChat.version)
            ],
            method: .get
        )
        
        socketService.connect(socketURL: try socketEndpoint.urlRequest())
    }
    
    /// - Throws: ``CXoneChatError/channelConfigFailure`` if the SDK could not prepare URL for URLRequest
    /// - Throws: ``CXoneChatError/customerAssociationFailure`` if the SDK could not get customer identity and it may not have been set.
    /// - Throws: ``CXoneChatError/missingAccessToken`` if the customer was successfully authorized, but an access token wasn't returned.
    /// - Throws: ``EncodingError.invalidValue(_:_:)`` if the given value is invalid in the current context for this format.
    /// - Throws: ``URLError.badServerResponse`` if the URL Loading system received bad data from the server.
    /// - Throws: ``NSError`` object that indicates why the request failed
    func checkForAuthorization() async throws {
        LogManager.trace("Checking authorization.")
        
        if connectionContext.customer == nil {
            let idOnExternalPlatform = UUID().uuidString
            connectionContext.customer = CustomerIdentityDTO(idOnExternalPlatform: idOnExternalPlatform, firstName: nil, lastName: nil)
            
            try await createOrUpdateVisitor(visitorId: connectionContext.visitorId.unsafelyUnwrapped, customerId: idOnExternalPlatform)
            
            try authorizeCustomer()
        } else if connectionContext.channelConfig.isAuthorizationEnabled {
            try reconnectCustomer()
        } else {
            try authorizeCustomer()
        }
    }
    
    /// Authorizes a new customer to communicate through the WebSocket.
    /// - Throws: ``CXoneChatError/customerAssociationFailure`` if the SDK could not get customer identity and it may not have been set.
    /// - Throws: ``EncodingError.invalidValue(_:_:)`` if the given value is invalid in the current context for this format.
    func authorizeCustomer() throws {
        LogManager.trace("Authorizing customer.")
        
        let data = try eventsService.create(
            .authorizeCustomer,
            with: .authorizeCustomerData(
                AuthorizeCustomerEventDataDTO(
                    authorizationCode: connectionContext.authorizationCode,
                    codeVerifier: connectionContext.codeVerifier
                )
            )
        )
        
        socketService.send(message: data.utf8string, shouldCheck: false)
    }
    
    /// Reconnects a returning customer to communicate through the WebSocket.
    /// - Throws: ``CXoneChatError/customerAssociationFailure`` if the SDK could not get customer identity and it may not have been set.
    /// - Throws: ``CXoneChatError/missingAccessToken`` if the customer was successfully authorized, but an access token wasn't returned.
    /// - Throws: ``EncodingError.invalidValue(_:_:)`` if the given value is invalid in the current context for this format.
    func reconnectCustomer() throws {
        LogManager.trace("Reconnecting customer.")
        
        guard let token = socketService.accessToken?.token else {
            throw CXoneChatError.missingAccessToken
        }
        
        let data = try eventsService.create(.reconnectCustomer, with: .reconnectCustomerData(ReconnectCustomerEventDataDTO(token: token)))
        
        socketService.send(message: data.utf8string)
    }
    
    /// - Throws: ``CXoneChatError/channelConfigFailure`` if the SDK could not prepare URL for URLRequest
    /// - Throws: ``URLError.badServerResponse`` if the URL Loading system received bad data from the server.
    /// - Throws: ``NSError`` object that indicates why the request failed
    func createOrUpdateVisitor(visitorId: UUID, customerId: String) async throws {
        LogManager.trace("Creating or updating visitor.")
        
        guard let base = URL(string: connectionContext.environment.chatURL),
              let url = URL(
                string: "/web-analytics/1.0/tenants/\(connectionContext.brandId)/visitors/\(visitorId.uuidString)",
                relativeTo: base
              )
        else {
            throw CXoneChatError.channelConfigFailure
        }

        try await Task
            .retrying {
                var request = URLRequest(url: url, method: .put, contentType: "application/json")
                request.httpBody = try JSONEncoder().encode(
                    VisitorDTO(
                        customerIdentity: CustomerIdentityDTO(idOnExternalPlatform: customerId),
                        browserFingerprint: DeviceFingerprintDTO(deviceToken: self.connectionContext.deviceToken),
                        journey: nil,
                        customVariables: nil
                    )
                )
                
                try await self.connectionContext.session.data(for: request)
            }
            .value
    }
}
