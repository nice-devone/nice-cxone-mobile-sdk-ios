//
// Copyright (c) 2021-2025. NICE Ltd. All rights reserved.
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

import Combine
import CXoneGuideUtility
import Foundation

class ConnectionService {

    // MARK: - Properties
    
    // To be able to retry getting channel configuration in case of transient errors
    static var getChannelRetryAttempts = 3
    
    let delegate: CXoneChatDelegate
    let transactionTokenService: TransactionTokenService
    var socketService: SocketService
    var eventsService: EventsService
    var customerService: CustomerService?
    var threadsService: ChatThreadListService?
    var customerFieldsService: CustomerCustomFieldsService?
    var registerListeners: (() -> Void)?
    
    var connectionContext: ConnectionContext {
        socketService.connectionContext
    }
    
    // MARK: - Protocol Properties
    
    var events: AnyPublisher<any ReceivedEvent, Never> {
        socketService.events
    }
    var cancellables: [AnyCancellable] {
        get { socketService.cancellables }
        set { socketService.cancellables = newValue }
    }
    var channelConfiguration: ChannelConfiguration {
        ChannelConfigurationMapper.map(connectionContext.channelConfig)
    }
    
    // MARK: - Init
    
    init(
        customer: CustomerProvider,
        threads: ChatThreadListProvider,
        customerFields: CustomerCustomFieldsProvider,
        socketService: SocketService,
        eventsService: EventsService,
        delegate: CXoneChatDelegate
    ) {
        self.customerService = customer as? CustomerService
        self.threadsService = threads as? ChatThreadListService
        self.customerFieldsService = customerFields as? CustomerCustomFieldsService
        self.socketService = socketService
        self.eventsService = eventsService
        self.delegate = delegate
        self.transactionTokenService = TransactionTokenService(connectionContext: socketService.connectionContext)

        socketService.delegate = self
    }
}

// MARK: - ConnectionProvider

extension ConnectionService: ConnectionProvider {

    /// - Throws: ``CXoneChatError/channelConfigFailure`` if provided parameters do not create a valid URL.
    /// - Throws: ``CXoneChatError/sdkVersionNotSupported`` if the SDK version is not supported by the server.
    /// - Throws: ``DecodingError.dataCorrupted`` an indication that the data is corrupted or otherwise invalid.
    /// - Throws: ``DecodingError.typeMismatch`` if the encountered stored value is not a JSON object or otherwise cannot be converted to the required type.
    /// - Throws: ``DecodingError.keyNotFound`` if the response does not have an entry for the given key.
    /// - Throws: ``DecodingError.valueNotFound`` if a response has a null value for the given key.
    /// - Throws: ``URLError.badServerResponse`` if the URL Loading system received bad data from the server.
    /// - Throws: ``NSError`` object that indicates why the request failed
    func getChannelConfiguration(environment: Environment, brandId: Int, channelId: String) async throws -> ChannelConfiguration {
        LogManager.trace("Getting channel configuration")

        guard let url = environment.chatServerUrl?.channelUrl(brandId: brandId, channelId: channelId) else {
            throw CXoneChatError.channelConfigFailure
        }

        return ChannelConfigurationMapper.map(try await getChannelConfiguration(url: url))
    }
    
    /// - Throws: ``CXoneChatError/channelConfigFailure`` if provided parameters do not create a valid URL.
    /// - Throws: ``CXoneChatError/sdkVersionNotSupported`` if the SDK version is not supported by the server.
    /// - Throws: ``DecodingError.dataCorrupted`` an indication that the data is corrupted or otherwise invalid.
    /// - Throws: ``DecodingError.typeMismatch`` if the encountered stored value is not a JSON object or otherwise cannot be converted to the required type.
    /// - Throws: ``DecodingError.keyNotFound`` if the response does not have an entry for the given key.
    /// - Throws: ``DecodingError.valueNotFound`` if a response has a null value for the given key.
    /// - Throws: ``URLError.badServerResponse`` if the URL Loading system received bad data from the server.
    /// - Throws: ``NSError`` object that indicates why the request failed
    func getChannelConfiguration(chatURL: String, brandId: Int, channelId: String) async throws -> ChannelConfiguration {
        LogManager.trace("Getting channel configuration")

        guard let url = URL(string: chatURL)?.channelUrl(brandId: brandId, channelId: channelId) else {
            throw CXoneChatError.channelConfigFailure
        }

        return ChannelConfigurationMapper.map(try await getChannelConfiguration(url: url))
    }
    
    /// - Throws: ``CXoneChatError/illegalChatState`` if the SDK is not in the required state to trigger the method.
    /// - Throws: ``CXoneChatError/missingParameter(_:)`` if connection`url` is not in correct format.
    /// - Throws: ``CXoneChatError/channelConfigFailure`` if the SDK could not prepare URL for URLRequest
    /// - Throws: ``DecodingError.dataCorrupted`` an indication that the data is corrupted or otherwise invalid.
    /// - Throws: ``DecodingError.typeMismatch`` if the encountered stored value is not a JSON object or otherwise cannot be converted to the required type.
    /// - Throws: ``DecodingError.keyNotFound`` if the response does not have an entry for the given key.
    /// - Throws: ``DecodingError.valueNotFound`` if a response has a null value for the given key.
    /// - Throws: ``URLError.badServerResponse`` if the URL Loading system received bad data from the server.
    /// - Throws: ``NSError`` object that indicates why the request failed
    /// - Throws: `EncodingError.invalidValue` if a non-conforming floating-point value is encountered during encoding, and the encoding strategy is `.throw`.
    /// - Throws: An error if any value throws an error during encoding.
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
    
    /// - Throws: ``CXoneChatError/illegalChatState`` if the SDK is not in the required state to trigger the method.
    /// - Throws: ``CXoneChatError/missingParameter(_:)`` if connection`url` is not in correct format.
    /// - Throws: ``CXoneChatError/channelConfigFailure`` if the SDK could not prepare URL for URLRequest
    /// - Throws: ``DecodingError.dataCorrupted`` an indication that the data is corrupted or otherwise invalid.
    /// - Throws: ``DecodingError.typeMismatch`` if the encountered stored value is not a JSON object or otherwise cannot be converted to the required type.
    /// - Throws: ``DecodingError.keyNotFound`` if the response does not have an entry for the given key.
    /// - Throws: ``DecodingError.valueNotFound`` if a response has a null value for the given key.
    /// - Throws: ``URLError.badServerResponse`` if the URL Loading system received bad data from the server.
    /// - Throws: ``NSError`` object that indicates why the request failed
    /// - Throws: `EncodingError.invalidValue` if a non-conforming floating-point value is encountered during encoding, and the encoding strategy is `.throw`.
    /// - Throws: An error if any value throws an error during encoding.
    @available(*, deprecated, message: "Replaced with prepare(chatURL:socketURL:brandId:channelId:loggerURL:) to be able to use additional logger.")
    func prepare(chatURL: String, socketURL: String, brandId: Int, channelId: String) async throws {
        try await prepare(chatURL: chatURL, socketURL: socketURL, loggerURL: "", brandId: brandId, channelId: channelId)
    }
    
    /// - Throws: ``CXoneChatError/illegalChatState`` if the SDK is not in the required state to trigger the method.
    /// - Throws: ``CXoneChatError/missingParameter(_:)`` if connection`url` is not in correct format.
    /// - Throws: ``CXoneChatError/channelConfigFailure`` if the SDK could not prepare URL for URLRequest
    /// - Throws: ``DecodingError.dataCorrupted`` an indication that the data is corrupted or otherwise invalid.
    /// - Throws: ``DecodingError.typeMismatch`` if the encountered stored value is not a JSON object or otherwise cannot be converted to the required type.
    /// - Throws: ``DecodingError.keyNotFound`` if the response does not have an entry for the given key.
    /// - Throws: ``DecodingError.valueNotFound`` if a response has a null value for the given key.
    /// - Throws: ``URLError.badServerResponse`` if the URL Loading system received bad data from the server.
    /// - Throws: ``NSError`` object that indicates why the request failed
    /// - Throws: `EncodingError.invalidValue` if a non-conforming floating-point value is encountered during encoding, and the encoding strategy is `.throw`.
    /// - Throws: An error if any value throws an error during encoding.
    @available(*, deprecated, message: "Replaced with prepare(chatURL:socketURL:loggerURL:brandId:channelId:tokenURL:) to support tokenURL parameter.")
    func prepare(chatURL: String, socketURL: String, loggerURL: String, brandId: Int, channelId: String) async throws {
        try await prepare(chatURL: chatURL, socketURL: socketURL, loggerURL: loggerURL, brandId: brandId, channelId: channelId, tokenURL: nil)
    }

    /// - Throws: ``CXoneChatError/illegalChatState`` if the SDK is not in the required state to trigger the method.
    /// - Throws: ``CXoneChatError/missingParameter(_:)`` if connection`url` is not in correct format.
    /// - Throws: ``CXoneChatError/channelConfigFailure`` if the SDK could not prepare URL for URLRequest
    /// - Throws: ``DecodingError.dataCorrupted`` an indication that the data is corrupted or otherwise invalid.
    /// - Throws: ``DecodingError.typeMismatch`` if the encountered stored value is not a JSON object or otherwise cannot be converted to the required type.
    /// - Throws: ``DecodingError.keyNotFound`` if the response does not have an entry for the given key.
    /// - Throws: ``DecodingError.valueNotFound`` if a response has a null value for the given key.
    /// - Throws: ``URLError.badServerResponse`` if the URL Loading system received bad data from the server.
    /// - Throws: ``NSError`` object that indicates why the request failed
    /// - Throws: `EncodingError.invalidValue` if a non-conforming floating-point value is encountered during encoding, and the encoding strategy is `.throw`.
    /// - Throws: An error if any value throws an error during encoding.
    func prepare(chatURL: String, socketURL: String, loggerURL: String, brandId: Int, channelId: String, tokenURL: String?) async throws {
        // swiftlint:disable:previous function_parameter_count
        if connectionContext.chatState == .preparing {
            return
        }
        guard connectionContext.chatState.isPrepareable else {
            throw CXoneChatError.illegalChatState
        }
        
        LogManager.trace("Preparing SDK for connection with custom environment")

        connectionContext.environment = CustomEnvironment(
            chatURL: chatURL,
            socketURL: socketURL,
            // `nil` value allows to evaluate the URL from the chat URL
            loggerURL: loggerURL.isEmpty ? nil : loggerURL,
            tokenURL: tokenURL
        )
        
        try await prepare(brandId: brandId, channelId: channelId)
    }
    
    /// - Throws: ``CXoneChatError/illegalChatState`` if the SDK is not in the required state to trigger the method.
    /// - Throws: ``CXoneChatError/customerAssociationFailure`` if the SDK could not get customer identity and it may not have been set.
    /// - Throws: ``CXoneChatError/missingAccessToken`` if the customer was successfully authorized, but an access token wasn't returned.
    /// - Throws: ``CXoneChatError/transactionTokenExpired`` if the transaction token is expired.
    /// - Throws: ``CXoneChatError/invalidData`` when the Data object cannot be successfully converted to a valid UTF-8 string
    /// - Throws: ``CXoneChatError/invalidParameter(_:)`` if the socket endpoint URL has not been set properly
    /// - Throws: ``CXoneChatError/channelConfigFailure`` if the SDK could not prepare URL for URLRequest
    /// - Throws: ``CXoneChatError/notConnected`` if the pulse was not received
    /// - Throws: ``CXoneChatError/missingVisitorId`` if visitor ID is not set.
    /// - Throws: ``CXoneChatError/missingParameter(_:)`` if unable to build the URL.
    /// - Throws: ``CXoneChatError/missingParameter(_:)`` if unable to get cached transaction token.
    /// - Throws: ``EncodingError.invalidValue(_:_:)`` if the given value is invalid in the current context for this format.
    /// - Throws: ``URLError.badServerResponse`` if the URL Loading system received bad data from the server.
    /// - Throws: ``NSError`` object that indicates why the request failed
    func connect() async throws {
        if connectionContext.chatState == .connecting {
            // Calling `connect` in `.connecting` state is ignored
            return
        }
        if connectionContext.chatState.isChatAvailable {
            delegate.onChatUpdated(connectionContext.chatState, mode: connectionContext.chatMode)
            return
        }
        
        guard connectionContext.chatState == .prepared else {
            throw CXoneChatError.illegalChatState
        }
        
        if connectionContext.chatMode == .liveChat, try await !isLiveChatAvailable() {
            LogManager.trace("Chat mode is live chat but the chat is offline")
            
            connectionContext.chatState = .offline
            delegate.onChatUpdated(connectionContext.chatState, mode: connectionContext.chatMode)
        } else {
            LogManager.trace("Setting `state` to `connecting` and connecting to the CXone service")
            
            connectionContext.chatState = .connecting
            delegate.onChatUpdated(connectionContext.chatState, mode: connectionContext.chatMode)
            
            try await connectToSocket()
            
            try await startAutomatedConnectionFlow()
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

            socketService.disconnect(unexpectedly: false)
        }
    }
    
    /// - Throws: ``CXoneChatError/illegalChatState`` if the SDK is not in the required state to trigger the method.
    /// - Throws: ``CXoneChatError/notConnected`` if an attempt was made to use a method without connecting first.
    ///     Make sure you call the `connect` method first.
    /// - Throws: ``CXoneChatError/customerVisitorAssociationFailure`` if the customer could not be associated with a visitor.
    /// - Throws: ``CXoneChatError/customerAssociationFailure`` The SDK instance could not get customer identity possibly because it may not have been set.
    /// - Throws: ``CXoneChatError/invalidData`` when the Data object cannot be successfully converted to a valid UTF-8 string
    /// - Throws: ``EncodingError.invalidValue(_:_:)`` if the given value is invalid in the current context for this format.
    /// - Throws: An error if any value throws an error during encoding.
    @available(*, deprecated, message: "Use alternative with `String` parameter. It preserves the original case-sensitive identifier from the backend.")
    func executeTrigger(_ triggerId: UUID) async throws { // swiftlint:disable:this no_uuid
        try await executeTrigger(triggerId.uuidString)
    }
    
    /// - Throws: ``CXoneChatError/illegalChatState`` if the SDK is not in the required state to trigger the method.
    /// - Throws: ``CXoneChatError/notConnected`` if an attempt was made to use a method without connecting first.
    ///     Make sure you call the `connect` method first.
    /// - Throws: ``CXoneChatError/customerVisitorAssociationFailure`` if the customer could not be associated with a visitor.
    /// - Throws: ``CXoneChatError/customerAssociationFailure`` The SDK instance could not get customer identity possibly because it may not have been set.
    /// - Throws: ``CXoneChatError/invalidData`` when the Data object cannot be successfully converted to a valid UTF-8 string
    /// - Throws: ``EncodingError.invalidValue(_:_:)`` if the given value is invalid in the current context for this format.
    /// - Throws: An error if any value throws an error during encoding.
    func executeTrigger(_ triggerId: String) async throws {
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
            eventId: connectionContext.destinationId,
            visitorId: visitorId,
            triggerId: triggerId
        )

        let data = try JSONEncoder().encode(ExecuteTriggerEventDTO(action: .chatWindowEvent, eventId: LowercaseUUID().uuidString, payload: payload))

        try await socketService.send(data: data)
    }
}

// MARK: - EventReceiver

extension ConnectionService: EventReceiver {
    
    func addListeners() {
        addListener(onOperationError)
    }
    
    func onOperationError(_ error: OperationError) {
        switch error.errorCode {
        case .customerReconnectFailed, .consumerReconnectFailed:
            Task { [weak self] in
                do {
                    try await self?.refreshToken()
                } catch {
                    error.logError()
                    
                    self?.delegate.onError(error)
                }
            }
        default:
            // Other errors are handled in the SocketService
            break
        }
    }
}

// MARK: - Internal Methods

extension ConnectionService {
    
    func signOut() {
        LogManager.trace("Signing out an user")
        
        socketService.disconnect(unexpectedly: false)
        
        connectionContext.clear()
    }
}

// MARK: - Private methods

private extension ConnectionService {
    
    /// - Throws: ``CXoneChatError/sdkVersionNotSupported`` if the SDK version is not supported by the server.
    /// - Throws: ``DecodingError.dataCorrupted`` an indication that the data is corrupted or otherwise invalid.
    /// - Throws: ``DecodingError.typeMismatch`` if the encountered stored value is not a JSON object or otherwise cannot be converted to the required type.
    /// - Throws: ``DecodingError.keyNotFound`` if the response does not have an entry for the given key.
    /// - Throws: ``DecodingError.valueNotFound`` if a response has a null value for the given key.
    /// - Throws: ``URLError.badServerResponse`` if the URL Loading system received bad data from the server.
    /// - Throws: ``NSError`` object that indicates why the request failed
    func getChannelConfiguration(url: URL) async throws -> ChannelConfigurationDTO {
        try await Task
            .retrying(attempts: Self.getChannelRetryAttempts) {
                let (data, _) = try await self.connectionContext.session.fetch(from: url)

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
    /// - Throws: `EncodingError.invalidValue` if a non-conforming floating-point value is encountered during encoding, and the encoding strategy is `.throw`.
    /// - Throws: An error if any value throws an error during encoding.
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
            
            // Configure the client logger since all necessary paramenters are set
            LogManager.configureInternalLogger(connectionContext: connectionContext)
            
            LogManager.trace("Did set channel configuration for the SDK")
            
            connectionContext.destinationId = LowercaseUUID().uuidString
            
            let visitorId: String = connectionContext.visitorId ?? {
                LogManager.trace("Creating new visitor ID")
                
                let visitorId = LowercaseUUID().uuidString
                connectionContext.visitorId = visitorId
                
                return visitorId
            }()
            let customerId: String = connectionContext.customer?.idOnExternalPlatform ?? {
                let customerId = LowercaseUUID().uuidString
                customerService?.createCustomer(with: customerId)
                
                return customerId
            }()
            
            try await createOrUpdateVisitor(visitorId: visitorId, customerId: customerId)
            
            connectionContext.chatState = .prepared
            
            delegate.onChatUpdated(connectionContext.chatState, mode: connectionContext.chatMode)
        } catch {
            connectionContext.chatState = .initial
            
            throw error
        }
    }
    
    /// - Throws: ``CXoneChatError/invalidParameter(_:)`` if the socket endpoint URL has not been set properly
    /// - Throws: ``CXoneChatError/notConnected`` if the pulse was not received
    /// - Throws: ``CXoneChatError/transactionTokenExpired`` if the transaction token is expired.
    /// - Throws: ``CXoneChatError/transactionTokenRequestFailed`` if the transaction token request fails
    /// - Throws: ``CXoneChatError/missingVisitorId`` if visitor ID is not set.
    /// - Throws: ``CXoneChatError/missingParameter(_:)`` if unable to build the URL.
    /// - Throws: ``CXoneChatError/missingParameter(_:)`` if unable to get cached transaction token.
    func connectToSocket() async throws {
        LogManager.trace("Connecting to the socket")

        // Log channel information for debugging
        LogManager.trace("Channel info - brandId: \(connectionContext.brandId), channelId: \(connectionContext.channelId)")

        // Build base query items
        var queryItems: [URLQueryItem] = [
            URLQueryItem(name: "brandId", value: connectionContext.brandId.description),
            URLQueryItem(name: "channelId", value: connectionContext.channelId),
            URLQueryItem(name: "visitorId", value: connectionContext.visitorId),
            URLQueryItem(name: "sdkPlatform", value: "ios"),
            URLQueryItem(name: "sdkVersion", value: CXoneChatSDKModule.version)
        ]

        // Request transaction token when secured sessions feature is enabled
        // When enabled, ALL authentication types require transaction tokens for WebSocket connection
        if connectionContext.channelConfig.settings.isSecuredSessionsEnabled {
            let authenticationType = connectionContext.channelConfig.authenticationType
            LogManager.trace("`SecuredSessions` toggle enabled -> requesting transaction token for \(authenticationType)")
            
            // Add transaction token to WebSocket query parameters
            queryItems.append(
                URLQueryItem(
                    name: "transactionToken",
                    value: try await getAndStoreTransactionTokenIfNeeded(for: authenticationType)
                )
            )
        } else {
            LogManager.trace("`SecuredSessions` toggle disabled -> using traditional authentication flow")
        }
        
        let socketEndpoint = SocketEndpointDTO(
            environment: connectionContext.environment,
            queryItems: queryItems,
            method: .get
        )
        
        guard let url = socketEndpoint.url else {
            throw CXoneChatError.invalidParameter("Configuration has invalid websocket url")
        }

        LogManager.trace("Connecting to WebSocket")

        try await socketService.connect(socketURL: url)
    }
    
    /// - Throws: ``CXoneChatError/transactionTokenExpired`` if the transaction token is expired.
    /// - Throws: ``CXoneChatError/missingVisitorId`` if visitor ID is not set.
    /// - Throws: ``CXoneChatError/missingParameter(_:)`` if unable to build the URL.
    /// - Throws: ``CXoneChatError/missingParameter(_:)`` if unable to get cached transaction token.
    /// - Throws: ``CXoneChatError/transactionTokenRequestFailed(statusCode:)`` if the request fails with a non-2xx status code.
    func getAndStoreTransactionTokenIfNeeded(for authenticationType: AuthenticationType) async throws -> String {
        // If the token is available & not expired -> return it's value
        if let token = connectionContext.transactionToken, !token.isExpired {
            LogManager.info("Cached transaction token is still valid")
            
            return token.value
        }
        // If the token is not available -> request a new one
        // If the token is available, expired and authentication type is not `.OAuth` -> request a new one
        else if connectionContext.transactionToken == nil || authenticationType != .thirdPartyOAuth {
            LogManager.trace("Transaction token is not available or expired, requesting a new one")
            
            let entity = try await transactionTokenService.requestTransactionToken(for: authenticationType)
            
            connectionContext.transactionToken = entity
            connectionContext.customer = connectionContext.customer?.copy(from: entity)
            
            return entity.value
        } else {
            LogManager.trace("Stored OAuth transaction is no longer valid. Resetting the chat state to allow OAuth flow re-trigger.")
            
            // We are not able to get the token based on previously stored authorization code and code verifier,
            // Set state from `.connecting` to `.prepared` so the connection flow can be retriggered
            connectionContext.chatState = .prepared
            
            throw CXoneChatError.transactionTokenExpired
        }
    }
    
    func startAutomatedConnectionFlow() async throws {
        LogManager.trace("Starting automated connection flow")
        
        connectionContext.chatState = .connected
        delegate.onChatUpdated(connectionContext.chatState, mode: connectionContext.chatMode)
        
        do {
            // Setup websocket event listeners
            if let registerListeners {
                registerListeners()
            } else {
                LogManager.error("Unable to register listeners for the socket events")
                
                socketService.disconnect(unexpectedly: true)
                return
            }
            
            try await checkForAuthorization()
        } catch {
            socketService.disconnect(unexpectedly: true)
            
            throw error
        }
    }
    
    /// - Throws: ``CXoneChatError/customerAssociationFailure`` if the SDK could not get customer identity and it may not have been set.
    /// - Throws: ``CXoneChatError/missingAccessToken`` if the customer was successfully authorized, but an access token wasn't returned.
    /// - Throws: ``CXoneChatError/invalidData`` when the Data object cannot be successfully converted to a valid UTF-8 string
    /// - Throws: ``CXoneChatError/invalidParameter(_:)`` if the threadsService is not correctly registered.
    /// - Throws: ``CXoneChatError/unsupportedChannelConfig`` if the method being called is not supported with the current channel configuration.
    /// - Throws: ``EncodingError.invalidValue(_:_:)`` if the given value is invalid in the current context for this format.
    func checkForAuthorization() async throws {
        LogManager.trace("Checking authorization")

        // When secured sessions feature is enabled, authorization happens during WebSocket handshake
        // via digital-oauth service for ALL authentication types
        // No need to send authorizeCustomer event - proceed directly to thread loading
        if connectionContext.channelConfig.settings.isSecuredSessionsEnabled {
            LogManager.trace("`SecuredSessions` toggle enabled -> proceed directly to thread loading")

            // Proceed directly to loading threads/reconnecting (same as after successful authorization)
            try await customerService?.processCustomerReconnectedEvent()
        } else {
            LogManager.trace("`SecuredSessions` toggle disabled -> continue with legacy authorization flow")

            // Traditional authorization flow (secured sessions feature disabled)
            if connectionContext.accessToken != nil {
                try await reconnectCustomer()
            } else {
                try await authorizeCustomer()
            }
        }
    }
    
    /// - Throws: ``CXoneChatError/customerAssociationFailure`` if the SDK could not get customer identity and it may not have been set.
    /// - Throws: ``CXoneChatError/invalidData`` when the Data object cannot be successfully converted to a valid UTF-8 string
    /// - Throws: ``EncodingError.invalidValue(_:_:)`` if the given value is invalid in the current context for this format.
    /// - Throws: ``CXoneChatError/missingAccessToken`` if the customer was successfully authorized, but an access token wasn't returned.
    /// - Throws: ``CXoneChatError/invalidThread`` if the provided ID for the thread was invalid, so the action could not be performed.
    /// - Throws: ``CXoneChatError/invalidParameter(_:)`` if the threadsService is not correctly registered.
    /// - Throws: ``CXoneChatError/unsupportedChannelConfig`` if the method being called is not supported with the current channel configuration.
    /// - Throws: ``EncodingError.invalidValue(_:_:)`` if the given value is invalid in the current context for this format.
    func authorizeCustomer() async throws {
        LogManager.trace("Authorizing customer")
        
        let event = try eventsService.create(
            event: .authorizeCustomer,
            with: .authorizeCustomerData(
                AuthorizeCustomerEventDataDTO(
                    authorizationCode: connectionContext.authorizationCode,
                    codeVerifier: connectionContext.codeVerifier
                )
            )
        )
        
        let response = try await events.sink(
            type: .customerAuthorized,
            as: CustomerAuthorizedEventDTO.self,
            origin: event,
            socketService: socketService,
            eventsService: eventsService,
            cancellables: &cancellables
        )
        
        try await customerService?.processCustomerAuthorizedEvent(response)
    }
    
    /// - Throws: ``CXoneChatError/customerAssociationFailure`` if the SDK could not get customer identity and it may not have been set.
    /// - Throws: ``CXoneChatError/missingAccessToken`` if the customer was successfully authorized, but an access token wasn't returned.
    /// - Throws: ``CXoneChatError/invalidData`` when the Data object cannot be successfully converted to a valid UTF-8 string
    /// - Throws: ``CXoneChatError/invalidParameter(_:)`` if the threadsService is not correctly registered.
    /// - Throws: ``CXoneChatError/unsupportedChannelConfig`` if the method being called is not supported with the current channel configuration.
    /// - Throws: ``EncodingError.invalidValue(_:_:)`` if the given value is invalid in the current context for this format.
    func reconnectCustomer() async throws {
        LogManager.trace("Reconnecting customer")
        
        guard let token = connectionContext.accessToken?.token else {
            throw CXoneChatError.missingAccessToken
        }
        
        let event = try eventsService.create(
            event: .reconnectCustomer,
            with: .reconnectCustomerData(ReconnectCustomerEventDataDTO(token: token))
        )
        
        try await events.sink(
            type: .customerReconnected,
            as: GenericEventDTO.self,
            origin: event,
            socketService: socketService,
            eventsService: eventsService,
            cancellables: &cancellables
        )
        
        try await customerService?.processCustomerReconnectedEvent()
    }
    
    /// - Throws: ``CXoneChatError/channelConfigFailure`` if the SDK could not prepare URL for URLRequest
    /// - Throws: ``URLError.badServerResponse`` if the URL Loading system received bad data from the server.
    /// - Throws: ``NSError`` object that indicates why the request failed
    /// - Throws: `EncodingError.invalidValue` if a non-conforming floating-point value is encountered during encoding, and the encoding strategy is `.throw`.
    /// - Throws: An error if any value throws an error during encoding.
    func createOrUpdateVisitor(visitorId: String, customerId: String) async throws {
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
                
                try await self.connectionContext.session.fetch(for: request, file: #file)
            }
            .value
    }
    
    /// - Throws: ``CXoneChatError/channelConfigFailure`` if the SDK could not prepare URL for URLRequest
    /// - Throws: ``URLError.badServerResponse`` if the URL Loading system received bad data from the server.
    /// - Throws: ``NSError`` object that indicates why the request failed
    func isLiveChatAvailable() async throws -> Bool {
        guard connectionContext.channelConfig.liveChatAvailability.expires <= Date() else {
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
                let (data, _) = try await self.connectionContext.session.fetch(from: url)
                let response = try JSONDecoder().decode(LiveChatAvailabilityDTO.self, from: data)
                
                return response.isOnline
            }
            .value
        
        connectionContext.channelConfig = connectionContext.channelConfig.copy(
            liveChatAvailability: CurrentLiveChatAvailability(
                isChannelLiveChat: connectionContext.chatMode == .liveChat,
                isOnline: isOnline,
                expires: Date().addingTimeInterval(CurrentLiveChatAvailability.expirationInterval)
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

// MARK: - SocketDelegate

extension ConnectionService: SocketDelegate {
    
    func didReceive(error: any Error) {
        delegate.onError(error)
    }

    func didCloseConnection(unexpectedly: Bool) {
        LogManager.trace("Websocket connection has been closed")

        connectionContext.chatState = .prepared

        if unexpectedly {
            delegate.onUnexpectedDisconnect()
        } else {
            delegate.onChatUpdated(connectionContext.chatState, mode: connectionContext.chatMode)
        }
    }

    /// - Throws: ``CXoneChatError/missingAccessToken`` if the customer was successfully authorized, but an access token wasn’t returned.
    /// - Throws: ``CXoneChatError/customerAssociationFailure`` if the SDK could not get customer identity and it may not have been set.
    /// - Throws: ``CXoneChatError/invalidData`` when the Data object cannot be successfully converted to a valid UTF-8 string
    /// - Throws: ``EncodingError.invalidValue(_:_:)`` if the given value is invalid in the current context for this format.
    func refreshToken() async throws {
        LogManager.trace("Refreshing a token")

        if connectionContext.channelConfig.settings.isSecuredSessionsEnabled {
            let entity = try await transactionTokenService.refreshAccessToken()
            
            LogManager.trace("Updating OAuth access token within transaction token")
            
            connectionContext.transactionToken = connectionContext.transactionToken?.copy(accessToken: entity)
        } else {
            guard let expiredToken = connectionContext.accessToken?.token else {
                throw CXoneChatError.missingAccessToken
            }

            let event = try eventsService.create(
                event: .refreshToken,
                with: .refreshTokenPayload(RefreshTokenPayloadDataDTO(token: expiredToken))
            )
            
            let response = try await events.sink(
                type: .tokenRefreshed,
                as: TokenRefreshedEventDTO.self,
                origin: event,
                checkTokenExpiration: false,
                socketService: socketService,
                eventsService: eventsService,
                cancellables: &cancellables
            )
            
            LogManager.trace("Saving an access token")
            
            connectionContext.accessToken = response.postback.accessToken
        }
    }
    
    func reconnect() async throws {
        LogManager.trace("Reconnecting to the web socket")
        
        try await startAutomatedConnectionFlow()
    }
}
