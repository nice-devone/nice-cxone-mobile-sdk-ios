//
// Copyright (c) 2021-2024. NICE Ltd. All rights reserved.
//
// Licensed under the NICE License;
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//    https://github.com/nice-devone/nice-cxone-mobile-sdk-ios/blob/main/LICENSE
//
// TO THE EXTENT PERMITTED BY APPLICABLE LAW, THE CXONE MOBILE SDK IS PROVIDED ON
// AN “AS IS” BASIS. NICE HEREBY DISCLAIMS ALL WARRANTIES AND CONDITIONS, EXPRESS
// OR IMPLIED, INCLUDING (WITHOUT LIMITATION) WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE, NON-INFRINGEMENT, AND TITLE.
//

import Foundation

class ConnectionService: ConnectionProvider {
    
    // MARK: - Properties
    
    weak var delegate: CXoneChatDelegate?
    
    var socketService: SocketService
    var eventsService: EventsService
    var customerService: CustomerService?
    var threadsService: ChatThreadsService?
    var customerFieldsService: CustomerCustomFieldsService?
    
    var dateProvider: DateProvider {
        socketService.dateProvider
    }
    var connectionContext: ConnectionContext {
        didSet {
            socketService.connectionContext = connectionContext
            eventsService.connectionContext = connectionContext
        }
    }
    
    // MARK: - Protocol Properties
    
    var channelConfiguration: ChannelConfiguration {
        ChannelConfigurationMapper.map(connectionContext.channelConfig)
    }
    
    // MARK: - Init
    
    init(
        connectionContext: ConnectionContext,
        customer: CustomerProvider,
        threads: ChatThreadsProvider,
        customerFields: CustomerCustomFieldsProvider,
        socketService: SocketService,
        eventsService: EventsService
    ) {
        self.connectionContext = connectionContext
        self.customerService = customer as? CustomerService
        self.threadsService = threads as? ChatThreadsService
        self.customerFieldsService = customerFields as? CustomerCustomFieldsService
        self.socketService = socketService
        self.eventsService = eventsService
    }
    
    // MARK: - Implementation
    
    /// - Throws: ``CXoneChatError/channelConfigFailure`` if provided parameters do not create a valid URL.
    /// - Throws: ``DecodingError.dataCorrupted`` an indication that the data is corrupted or otherwise invalid.
    /// - Throws: ``DecodingError.typeMismatch`` if the encountered stored value is not a JSON object or otherwise cannot be converted to the required type.
    /// - Throws: ``DecodingError.keyNotFound`` if the response does not have an entry for the given key.
    /// - Throws: ``DecodingError.valueNotFound`` if a response has a null value for the given key.
    func getChannelConfiguration(environment: Environment, brandId: Int, channelId: String) async throws -> ChannelConfiguration {
        LogManager.trace("Getting channel configuration")

        guard let url = environment.chatServerUrl?.channelUrl(brandId: brandId, channelId: channelId) else {
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
        LogManager.trace("Getting channel configuration")

        guard let url = URL(string: chatURL)?.channelUrl(brandId: brandId, channelId: channelId) else {
            throw CXoneChatError.channelConfigFailure
        }

        return ChannelConfigurationMapper.map(try await getChannelConfiguration(url: url))
    }
    
    /// Connects to the CXone service and configures the SDK for use.
    /// - Parameters:
    ///   - environment: The CXone ``Environment`` used to connect. Relates to your location.
    ///   - brandId: The unique id of the brand for which to open the connection.
    ///   - channelId: The unique id of the channel for the connection.
    ///
    /// - Throws: ``CXoneChatError/illegalChatState`` if it was unable to trigger the required method because the SDK is not in the required state
    /// - Throws: ``CXoneChatError/missingParameter(_:)`` if connection`url` is not in correct format.
    /// - Throws: ``CXoneChatError/channelConfigFailure`` if the SDK could not prepare URL for URLRequest
    /// - Throws: ``DecodingError.dataCorrupted`` an indication that the data is corrupted or otherwise invalid.
    /// - Throws: ``DecodingError.typeMismatch`` if the encountered stored value is not a JSON object or otherwise cannot be converted to the required type.
    /// - Throws: ``DecodingError.keyNotFound`` if the response does not have an entry for the given key.
    /// - Throws: ``DecodingError.valueNotFound`` if a response has a null value for the given key.
    /// - Throws: ``URLError.badServerResponse`` if the URL Loading system received bad data from the server.
    /// - Throws: ``NSError`` object that indicates why the request failed
    func prepare(environment: Environment, brandId: Int, channelId: String) async throws {
        if connectionContext.chatState == .preparing {
            return
        }
        guard connectionContext.chatState.isPrepareable else {
            throw CXoneChatError.illegalChatState
        }
        
        LogManager.trace("Preparing SDK for connection with default environment")
        
        connectionContext.environment = environment
        
        try await prepare(brandId: brandId, channelId: channelId)
    }
    
    /// Connects to the CXone service and configures the SDK for use.
    /// - Parameters:
    ///   - chatURL: The URL to be used for chat requests (channel config and attachment upload).
    ///   - socketURL: The URL to be used for the WebSocket connection.
    ///   - brandId: The unique id of the brand for which to open the connection.
    ///   - channelId: The unique id of the channel for the connection.
    ///
    /// - Throws: ``CXoneChatError/illegalChatState`` if it was unable to trigger the required method because the SDK is not in the required state
    /// - Throws: ``CXoneChatError/missingParameter(_:)`` if connection`url` is not in correct format.
    /// - Throws: ``CXoneChatError/channelConfigFailure`` if the SDK could not prepare URL for URLRequest
    /// - Throws: ``DecodingError.dataCorrupted`` an indication that the data is corrupted or otherwise invalid.
    /// - Throws: ``DecodingError.typeMismatch`` if the encountered stored value is not a JSON object or otherwise cannot be converted to the required type.
    /// - Throws: ``DecodingError.keyNotFound`` if the response does not have an entry for the given key.
    /// - Throws: ``DecodingError.valueNotFound`` if a response has a null value for the given key.
    /// - Throws: ``URLError.badServerResponse`` if the URL Loading system received bad data from the server.
    /// - Throws: ``NSError`` object that indicates why the request failed
    func prepare(chatURL: String, socketURL: String, brandId: Int, channelId: String) async throws {
        if connectionContext.chatState == .preparing {
            return
        }
        guard connectionContext.chatState.isPrepareable else {
            throw CXoneChatError.illegalChatState
        }
        
        LogManager.trace("Preparing SDK for connection with custom environment")
        
        connectionContext.environment = CustomEnvironment(chatURL: chatURL, socketURL: socketURL)
        
        try await prepare(brandId: brandId, channelId: channelId)
    }
    
    /// - Throws: ``CXoneChatError/illegalChatState`` if it was unable to trigger the required method because the SDK is not in the required state
    /// - Throws: ``CXoneChatError/webSocketConnectionFailure`` if the web socket refused to connect.
    /// - Throws: ``CXoneChatError/customerAssociationFailure`` if the SDK could not get customer identity and it may not have been set.
    /// - Throws: ``CXoneChatError/missingAccessToken`` if the customer was successfully authorized, but an access token wasn't returned.
    /// - Throws: ``CXoneChatError/invalidThread`` if the provided ID for the thread was invalid, so the action could not be performed.
    /// - Throws: ``EncodingError.invalidValue(_:_:)`` if the given value is invalid in the current context for this format.
    /// - Throws: ``URLError.badServerResponse`` if the URL Loading system received bad data from the server.
    /// - Throws: ``NSError`` object that indicates why the request failed
    func connect() async throws {
        if connectionContext.chatState == .connecting {
            // Calling `connect` in mentioned states is ignored
            return
        }
        if connectionContext.chatState.isChatAvailable {
            delegate?.onChatUpdated(connectionContext.chatState, mode: connectionContext.chatMode)
        }
        guard connectionContext.chatState == .prepared else {
            throw CXoneChatError.illegalChatState
        }
        
        if connectionContext.chatMode == .liveChat, try await !isLiveChatAvailable() {
            LogManager.trace("Chat mode is live chat but the chat is offline")
            
            connectionContext.chatState = .offline
            delegate?.onChatUpdated(connectionContext.chatState, mode: connectionContext.chatMode)
        } else {
            LogManager.trace("Setting `state` to `connecting` and connecting to the CXone service")
            
            connectionContext.chatState = .connecting
            delegate?.onChatUpdated(connectionContext.chatState, mode: connectionContext.chatMode)
            
            do {
                try connectToSocket()

                try await checkForAuthorization()
            } catch {
                disconnect()
                
                throw error
            }
        }
    }

    func disconnect() {
        if connectionContext.chatState == .preparing {
            LogManager.trace("Chat state has been stucked in `preparing` state –> changing to `initial`")
            
            connectionContext.chatState = .initial
        } else if connectionContext.chatState == .offline {
            LogManager.trace("Transitioning from 'offline' state to 'prepared' due to explicit disconnect action")
            
            connectionContext.chatState = .prepared
        } else if connectionContext.chatState > .prepared {
            LogManager.trace("Disconnecting from the CXone service and changing to `prepared`")

            socketService.disconnect()
        }
    }
    
    /// - Throws: ``CXoneChatError/illegalChatState`` if it was unable to trigger the required method because the SDK is not in the required state
    func ping() throws {
        guard connectionContext.chatState.isChatAvailable else {
            throw CXoneChatError.illegalChatState
        }
        
        LogManager.trace("Pinging the CXone chat server to ensure that a connection is established")

        socketService.ping()
    }
    
    /// - Throws: ``CXoneChatError/illegalChatState`` if it was unable to trigger the required method because the SDK is not in the required state
    /// - Throws: ``CXoneChatError/notConnected`` if an attempt was made to use a method without connecting first.
    ///     Make sure you call the `connect` method first.
    /// - Throws: ``CXoneChatError/customerVisitorAssociationFailure`` if the customer could not be associated with a visitor.
    /// - Throws: ``CXoneChatError/customerAssociationFailure`` The SDK instance could not get customer identity possibly because it may not have been set.
    /// - Throws: ``EncodingError.invalidValue(_:_:)`` if the given value is invalid in the current context for this format.
    /// - Throws: An error if any value throws an error during encoding.
    func executeTrigger(_ triggerId: UUID) throws {
        guard connectionContext.chatState.isChatAvailable else {
            throw CXoneChatError.illegalChatState
        }
        
        LogManager.trace("Executing trigger")

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
}

// MARK: - Internal Methods

extension ConnectionService {
    
    func signOut() {
        LogManager.trace("Signing out an user")
        
        socketService.disconnect()
        
        connectionContext.clear()
    }
}

// MARK: - Websocket Methods

extension ConnectionService {
    
    /// - Throws: ``CXoneChatError/missingAccessToken`` if the customer was successfully authorized, but an access token wasn’t returned.
    /// - Throws: ``CXoneChatError/customerAssociationFailure`` if the SDK could not get customer identity and it may not have been set.
    /// - Throws: ``EncodingError.invalidValue(_:_:)`` if the given value is invalid in the current context for this format.
    func refreshToken() throws {
        LogManager.trace("Refreshing a token")
        
        guard let token = socketService.accessToken?.token else {
            throw CXoneChatError.missingAccessToken
        }
        
        let data = try eventsService.create(.refreshToken, with: .refreshTokenPayload(RefreshTokenPayloadDataDTO(token: token)))
        
        socketService.send(message: data.utf8string, shouldCheck: false)
    }
    
    func saveAccessToken(_ decode: TokenRefreshedEventDTO?) {
        LogManager.trace("Saving a access token")
        
        socketService.accessToken = decode?.postback.accessToken
    }
    
    /// - Throws: ``CXoneChatError/invalidThread`` if the provided ID for the thread was invalid, so the action could not be performed.
    func processProactiveAction(_ data: Data) throws {
        LogManager.trace("Processing proactive action")
        
        let event = try data.decode() as ProactiveActionEventDTO
        
        switch event.data.actionType {
        case .welcomeMessage:
            LogManager.trace("Processing proactive action of type welcome message")
            
            guard let messageData = event.data.data?.content.bodyText else {
                throw CXoneChatError.invalidData
            }
            
            if let fields = event.data.data?.customFields {
                customerFieldsService?.updateFields(fields)
            }
            
            try threadsService?.handleWelcomeMessage(messageData)
            
            if let activeThread = connectionContext.activeThread {
                delegate?.onThreadUpdated(activeThread)
            }
        case .customPopupBox:
            LogManager.trace("Processing proactive action of type custom popup box")
            
            guard let dict = try? JSONSerialization.jsonObject(with: data) as? [String: Any] else {
                throw CXoneChatError.invalidData
            }
            
            let data = dict["data"] as? [String: Any]
            let proactiveAction = data?["proactiveAction"] as? [String: Any]
            let action = proactiveAction?["action"] as? [String: Any]
            let actionData = action?["data"] as? [String: Any]
            let content = actionData?["content"] as? [String: Any]
            let variables = content?["variables"] as? [String: Any]
            
            guard let actionId = action?["actionId"] as? String else {
                throw CXoneChatError.missingParameter("actionId")
            }
            guard let variables, !variables.isEmpty else {
                throw CXoneChatError.missingParameter("variables")
            }
            
            let id = UUID(uuidString: actionId) ?? UUID()
            
            delegate?.onProactivePopupAction(data: variables, actionId: id)
        }
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

    /// - Throws: ``CXoneChatError/missingParameter(_:)`` if connection`url` is not in correct format.
    /// - Throws: ``CXoneChatError/channelConfigFailure`` if the SDK could not prepare URL for URLRequest
    /// - Throws: ``DecodingError.dataCorrupted`` an indication that the data is corrupted or otherwise invalid.
    /// - Throws: ``DecodingError.typeMismatch`` if the encountered stored value is not a JSON object or otherwise cannot be converted to the required type.
    /// - Throws: ``DecodingError.keyNotFound`` if the response does not have an entry for the given key.
    /// - Throws: ``DecodingError.valueNotFound`` if a response has a null value for the given key.
    /// - Throws: ``URLError.badServerResponse`` if the URL Loading system received bad data from the server.
    /// - Throws: ``NSError`` object that indicates why the request failed
    func prepare(brandId: Int, channelId: String) async throws {
        LogManager.trace("Changing state to `preparing` and setting channel configuration to the brand: \(brandId) and channel: \(channelId)")
        
        connectionContext.chatState = .preparing
        
        guard let url = connectionContext.environment.chatServerUrl?.channelUrl(brandId: brandId, channelId: channelId) else {
            connectionContext.chatState = .initial
            throw CXoneChatError.missingParameter("url")
        }
        
        do {
            connectionContext.channelConfig = try await getChannelConfiguration(url: url)
            connectionContext.brandId = brandId
            connectionContext.channelId = channelId
            
            LogManager.trace("Did get channel configuration")
            
            connectionContext.destinationId = UUID()
            
            let visitorId: UUID = connectionContext.visitorId ?? {
                let visitorId = UUID()
                connectionContext.visitorId = visitorId
                
                return visitorId
            }()
            let customerId: String = connectionContext.customer?.idOnExternalPlatform ?? {
                let customerId = UUID()
                customerService?.createCustomer(customerId: customerId)
                
                return customerId.uuidString
            }()
            
            try await createOrUpdateVisitor(visitorId: visitorId, customerId: customerId)
            
            connectionContext.chatState = .prepared
            
            delegate?.onChatUpdated(connectionContext.chatState, mode: connectionContext.chatMode)
        } catch {
            connectionContext.chatState = .initial
            
            throw error
        }
    }
    
    /// - Throws: ``CXoneChatError/webSocketConnectionFailure`` if the web socket refused to connect.
    func connectToSocket() throws {
        LogManager.trace("Connecting to the socket")
        
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
        
        do {
            socketService.connect(socketURL: try socketEndpoint.urlRequest())
        } catch {
            error.logError()
            throw CXoneChatError.webSocketConnectionFailure
        }
    }
    
    /// - Throws: ``CXoneChatError/customerAssociationFailure`` if the SDK could not get customer identity and it may not have been set.
    /// - Throws: ``CXoneChatError/missingAccessToken`` if the customer was successfully authorized, but an access token wasn't returned.
    /// - Throws: ``EncodingError.invalidValue(_:_:)`` if the given value is invalid in the current context for this format.
    func checkForAuthorization() async throws {
        LogManager.trace("Checking authorization")
        
        if connectionContext.channelConfig.isAuthorizationEnabled {
            try reconnectCustomer()
        } else {
            try authorizeCustomer()
        }
    }
    
    /// Authorizes a new customer to communicate through the WebSocket.
    /// - Throws: ``CXoneChatError/customerAssociationFailure`` if the SDK could not get customer identity and it may not have been set.
    /// - Throws: ``EncodingError.invalidValue(_:_:)`` if the given value is invalid in the current context for this format.
    func authorizeCustomer() throws {
        LogManager.trace("Authorizing customer")
        
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
        LogManager.trace("Reconnecting customer")
        
        guard let token = socketService.accessToken?.token else {
            throw CXoneChatError.missingAccessToken
        }
        
        let data = try eventsService.create(.reconnectCustomer, with: .reconnectCustomerData(ReconnectCustomerEventDataDTO(token: token)))
        
        socketService.send(message: data.utf8string)
    }
    
    /// - Throws: ``CXoneChatError/channelConfigFailure`` if the SDK could not prepare URL for URLRequest
    /// - Throws: ``URLError.badServerResponse`` if the URL Loading system received bad data from the server.
    /// - Throws: ``NSError`` object that indicates why the request failed
    /// - Throws: `EncodingError.invalidValue` if a non-conforming floating-point value is encountered during encoding, and the encoding strategy is `.throw`.
    /// - Throws: An error if any value throws an error during encoding.
    func createOrUpdateVisitor(visitorId: UUID, customerId: String) async throws {
        LogManager.trace("Creating or updating visitor")
        
        guard let url = connectionContext.environment.webAnalyticsURL(brandId: connectionContext.brandId) / "visitors" / visitorId else {
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
    
    func isLiveChatAvailable() async throws -> Bool {
        guard connectionContext.channelConfig.liveChatAvailability.expires <= socketService.dateProvider.now else {
            return connectionContext.channelConfig.liveChatAvailability.isOnline
        }
        guard let url = connectionContext.environment.chatServerUrl?.liveChatAvailabilityUrl(
            brandId: connectionContext.brandId,
            channelId: connectionContext.channelId
        ) else {
            throw CXoneChatError.channelConfigFailure
        }
        
        let isOnline = try await Task
            .retrying {
                let (data, _) = try await self.connectionContext.session.data(from: url)
                let response = try JSONDecoder().decode(LiveChatAvailabilityDTO.self, from: data)
                
                return response.isOnline
            }
            .value
        
        connectionContext.channelConfig = connectionContext.channelConfig.copy(
            liveChatAvailability: CurrentLiveChatAvailability(
                isChannelLiveChat: connectionContext.chatMode == .liveChat,
                isOnline: isOnline,
                expires: dateProvider.now.addingTimeInterval(CurrentLiveChatAvailability.expirationInterval)
            )
        )
        
        return connectionContext.channelConfig.liveChatAvailability.isOnline
    }
}

// MARK: - Helpers

private extension URL {
    
    func channelUrl(brandId: Int, channelId: String) -> URL? {
        self / "1.0" / "brand" / brandId / "channel" / channelId
    }
    
    func liveChatAvailabilityUrl(brandId: Int, channelId: String) -> URL? {
        channelUrl(brandId: brandId, channelId: channelId) / "availability"
    }
}
