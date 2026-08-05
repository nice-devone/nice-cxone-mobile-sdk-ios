//
// Copyright (c) 2021-2026. NICE Ltd. All rights reserved.
//
// Licensed under the NICE License;
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//    https://github.com/nice-devone/nice-cxone-mobile-sdk-ios/blob/main/LICENSE
//
// TO THE EXTENT PERMITTED BY APPLICABLE LAW, THE CXONE MOBILE SDK IS PROVIDED ON
// AN "AS IS" BASIS. NICE HEREBY DISCLAIMS ALL WARRANTIES AND CONDITIONS, EXPRESS
// OR IMPLIED, INCLUDING (WITHOUT LIMITATION) WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE, NON-INFRINGEMENT, AND TITLE.
//

import CXoneGuideUtility
import Foundation

final class ConnectionService: Sendable {

    // MARK: - Properties

    let broadcaster: EventBroadcaster
    let transactionTokenService: TransactionTokenService
    let socketService: SocketService
    let eventsService: EventsService
    let customerService: CustomerService?
    let threadsService: ChatThreadListService?
    let customerFieldsService: CustomerCustomFieldsService?
    
    let registerListeners = SafeAccessContainer<(@Sendable () -> Void)?>(nil)

    /// Serialises implicit-flow token refreshes so concurrent outbound operations queue behind one refresh.
    private let tokenRefreshCoordinator = TokenRefreshCoordinator()

    /// HTTP status the backend returns when it rejects the connection token, triggering a delegate refresh.
    /// Matches the Android SDK's token-rejection check (`httpStatusCode == 401`).
    private static let tokenRejectionStatusCode = 401

    var connectionContext: ConnectionContext {
        socketService.connectionContext
    }

    private let encoder = JSONEncoder()
    private let decoder = JSONDecoder()
    private let getChannelRetryAttempts: Int
    
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
        broadcaster: EventBroadcaster,
        retryAttempts: Int = 3
    ) {
        self.customerService = customer as? CustomerService
        self.threadsService = threads as? ChatThreadListService
        self.customerFieldsService = customerFields as? CustomerCustomFieldsService
        self.socketService = socketService
        self.eventsService = eventsService
        self.broadcaster = broadcaster
        self.transactionTokenService = TransactionTokenService(connectionContext: socketService.connectionContext)
        self.getChannelRetryAttempts = retryAttempts

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
    /// - Throws: ``CXoneChatError/featureUnavailable(_:)`` if the method is triggered for OAuth explicit authentication type.
    /// - Throws: ``CXoneChatError/customerAssociationFailure`` if the SDK could not get customer identity and it may not have been set.
    /// - Throws: ``CXoneChatError/missingAccessToken`` if the customer was successfully authorized, but an access token wasn't returned.
    /// - Throws: ``CXoneChatError/invalidAccessToken`` if the OAuth token was rejected or is missing.
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
            broadcaster.send(.chatUpdated(state: connectionContext.chatState, mode: connectionContext.chatMode))
            return
        }
        
        guard connectionContext.chatState == .prepared else {
            throw CXoneChatError.illegalChatState
        }

        if connectionContext.chatMode == .liveChat, try await !isLiveChatAvailable() {
            LogManager.trace("Chat mode is live chat but the chat is offline")
            
            connectionContext.chatState = .offline
            broadcaster.send(.chatUpdated(state: connectionContext.chatState, mode: connectionContext.chatMode))
        } else {
            LogManager.trace("Setting `state` to `connecting` and connecting to the CXone service")

            connectionContext.chatState = .connecting
            broadcaster.send(.chatUpdated(state: connectionContext.chatState, mode: connectionContext.chatMode))

            do {
                try await connectToSocket()
            } catch {
                // Any failure while connecting (token refresh, transaction-token exchange, or the WebSocket
                // handshake itself) must reset the state machine to `.prepared`, or the `.prepared` guard
                // above rejects every subsequent `connect()` and the SDK is stranded at `.connecting`.
                connectionContext.chatState = .prepared

                throw error
            }

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

        let data = try encoder.encode(ExecuteTriggerEventDTO(action: .chatWindowEvent, eventId: LowercaseUUID().uuidString, payload: payload))

        try await socketService.send(data: data)
    }
}

// MARK: - Internal Methods

extension ConnectionService {
    
    func signOut() {
        LogManager.trace("Signing out an user")

        socketService.disconnect(unexpectedly: false)

        connectionContext.clear()

        broadcaster.invalidate()
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
            .retrying(attempts: getChannelRetryAttempts) {
                let (data, _) = try await self.connectionContext.session.fetch(from: url)

                return try self.decoder.decode(ChannelConfigurationDTO.self, from: data)
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
            await LogManager.configureInternalLogger(connectionContext: connectionContext)
            
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

            broadcaster.send(.chatUpdated(state: connectionContext.chatState, mode: connectionContext.chatMode))
        } catch {
            connectionContext.chatState = .initial
            
            throw error
        }
    }
    
    /// - Parameter forceRefresh: When `true`, bypass the local-expiry cache and mint a fresh transaction
    ///   token even if the cached one is still valid by the device clock. Used by the reconnect path
    ///   (``recreateSocketURL(forceRefresh:)``) to recover from a server-side token invalidation the local
    ///   expiry check cannot see. Skipped for explicit OAuth, which needs a fresh authorization code the
    ///   SDK cannot obtain silently.
    /// - Throws: ``CXoneChatError/missingVisitorId`` if visitor ID is not set.
    /// - Throws: ``CXoneChatError/missingParameter(_:)`` if unable to build the URL.
    /// - Throws: ``CXoneChatError/missingParameter(_:)`` if unable to get cached transaction token.
    /// - Throws: ``CXoneChatError/invalidAccessToken`` if the OAuth token was rejected by the backend.
    /// - Throws: ``CXoneChatError/featureUnavailable(_:)`` if the method is triggered for OAuth explicit authentication type.
    func getAndStoreTransactionTokenIfNeeded(for authenticationType: AuthenticationTypeDTO, forceRefresh: Bool = false) async throws -> String {
        // On reconnect the server may have invalidated a token that is still valid by the device clock.
        // Bypass the local-expiry cache so a fresh token is minted instead of the rejected one being replayed.
        // Skipped for explicit OAuth: it needs a fresh authorization code the SDK cannot obtain silently,
        // so it must fall through to the re-auth path rather than force-mint.
        let shouldForceMint = forceRefresh && authenticationType != .oAuthExplicit

        if !shouldForceMint, let token = connectionContext.reusableTransactionToken {
            LogManager.info("Cached transaction token is still valid")

            return token.value
        }

        do {
            LogManager.trace("Transaction token is not available or expired, requesting a new one")

            return try await requestAndStoreTransactionToken(for: authenticationType)
        } catch CXoneChatError.transactionTokenRequestFailed(let statusCode)
            where statusCode == Self.tokenRejectionStatusCode && authenticationType == .oAuthImplicit {
            // Implicit OAuth: the backend rejected the connection token (HTTP 401) even though it hadn't
            // timed out. With a listener, ask for a fresh token and retry the exchange once; without one
            // there is nothing to refresh with, so surface the documented invalid-token error either way
            // rather than leaking the raw HTTP failure (keeps the connect path consistent with the send path).
            guard connectionContext.tokenDelegateListener != nil else {
                LogManager.warning("Implicit OAuth: backend rejected the connection token (HTTP \(statusCode)) and no token delegate listener is registered")

                throw CXoneChatError.invalidAccessToken
            }

            LogManager.trace("Implicit OAuth: backend rejected the connection token (HTTP \(statusCode)) — refreshing via delegate and retrying")

            return try await refreshImplicitConnectionToken(reason: .tokenInvalid)
        } catch {
            error.logError()

            throw error
        }
    }

    /// Requests a transaction token for `authenticationType`, stores it, and refreshes the cached customer identity.
    func requestAndStoreTransactionToken(for authenticationType: AuthenticationTypeDTO) async throws -> String {
        let entity = try await transactionTokenService.requestTransactionToken(for: authenticationType)

        connectionContext.transactionToken = entity
        connectionContext.customer = connectionContext.customer?.copy(from: entity)

        return entity.value
    }

    /// Builds the WebSocket URL, re-minting the transaction token when the cached one is missing or
    /// expired. Shared by the initial connect (``connectToSocket()``) and the automatic reconnect
    /// (``recreateSocketURL(forceRefresh:)``) so both go through the same token handling.
    ///
    /// For the implicit OAuth flow, this also proactively refreshes the connection token (JWT) via the
    /// integrator's token delegate when the JWT is near expiry, before it is exchanged for a transaction
    /// token. Skipped when a still-valid transaction token is cached and no refresh is forced, since
    /// ``getAndStoreTransactionTokenIfNeeded(for:forceRefresh:)`` reuses it and never touches the JWT.
    ///
    /// - Parameter forceRefresh: When `true`, mint a fresh transaction token even if the cached one is still
    ///   valid by the device clock, and (for implicit OAuth) also refresh the JWT if it is near expiry.
    ///   Used by the reconnect path to recover from a server-side token invalidation the local expiry check
    ///   cannot see. Skipped for explicit OAuth, which needs a fresh authorization code the SDK cannot
    ///   obtain silently. The initial connect leaves this at its default (`false`).
    /// - Throws: ``CXoneChatError/transactionTokenRequestFailed(statusCode:)`` if the transaction-token exchange fails.
    /// - Throws: ``CXoneChatError/invalidParameter(_:)`` if the socket endpoint URL cannot be built.
    /// - Throws: ``CXoneChatError/invalidAccessToken`` if the OAuth token was rejected or is missing.
    /// - Throws: ``CXoneChatError/featureUnavailable(_:)`` if the method is triggered for OAuth explicit authentication type.
    func buildSocketURL(forceRefresh: Bool = false) async throws -> URL {
        LogManager.trace("Channel info - brandId: \(connectionContext.brandId), channelId: \(connectionContext.channelId)")

        // On a forced refresh (reconnect retry) also treat the token as needing refresh, so an implicit-OAuth
        // JWT that is near expiry is refreshed before the transaction-token exchange rather than replayed.
        //
        // The refresh-implicit path already mints and stores a fresh transaction token internally, so its
        // return value is used directly to skip a redundant `/oauth/token` round-trip on the reconnect hot
        // path. Falling through to `getAndStoreTransactionTokenIfNeeded` would otherwise bypass the just-
        // populated `reusableTransactionToken` cache when `forceRefresh == true`.
        let needsFreshTransactionToken = forceRefresh || connectionContext.reusableTransactionToken == nil
        let transactionToken: String
        if needsFreshTransactionToken,
           connectionContext.isImplicitConnectionTokenExpiring,
           connectionContext.tokenDelegateListener != nil {
            transactionToken = try await refreshImplicitConnectionToken(reason: .tokenExpired)
        } else {
            transactionToken = try await getAndStoreTransactionTokenIfNeeded(
                for: connectionContext.authenticationType,
                forceRefresh: forceRefresh
            )
        }
        let queryItems: [URLQueryItem] = [
            URLQueryItem(name: "brandId", value: connectionContext.brandId.description),
            URLQueryItem(name: "channelId", value: connectionContext.channelId),
            URLQueryItem(name: "visitorId", value: connectionContext.visitorId),
            URLQueryItem(name: "sdkPlatform", value: "ios"),
            URLQueryItem(name: "sdkVersion", value: CXoneChatSDKModule.version),
            URLQueryItem(name: "transactionToken", value: transactionToken)
        ]

        let socketEndpoint = SocketEndpointDTO(environment: connectionContext.environment, queryItems: queryItems, method: .get)

        guard let url = socketEndpoint.url else {
            throw CXoneChatError.invalidParameter("Configuration has invalid websocket url")
        }

        return url
    }
    
    /// Refreshes the implicit-flow connection token via the integrator's token delegate, single-flighted so
    /// concurrent callers await one in-flight refresh rather than each triggering their own.
    ///
    /// On success the fresh token is applied and re-exchanged for a new transaction token. When no listener
    /// is registered, or the listener or exchange fails, ``CXoneChatError/invalidAccessToken`` is thrown so
    /// the caller can abort the pending operation.
    ///
    /// - Parameter reason: Why the token is being refreshed; forwarded to the integrator's listener.
    /// - Returns: The refreshed transaction-token value.
    @discardableResult
    func refreshImplicitConnectionToken(reason: TokenRequestReason) async throws -> String {
        // A reactive refresh (the backend rejected the token) must run fresh rather than inherit an
        // in-flight proactive refresh's result, which may be the very token that was just rejected.
        try await tokenRefreshCoordinator.refresh(force: reason == .tokenInvalid) {
            try await self.performImplicitTokenRefresh(reason: reason)
        }
    }

    /// - Returns: The refreshed transaction-token value.
    /// - Throws: ``CXoneChatError/invalidAccessToken`` if no token delegate listener is registered, it fails,
    ///     or the backend rejects the refreshed token during the transaction-token exchange.
    func performImplicitTokenRefresh(reason: TokenRequestReason) async throws -> String {
        // A concurrent refresh may have already renewed the token while this call waited for the single-flight
        // slot. For a proactive (expiry-driven) refresh, reuse the fresh transaction token instead of calling
        // the delegate again. A reactive (`.tokenInvalid`) refresh always re-runs — the token was rejected.
        if reason == .tokenExpired,
           !connectionContext.isConnectionTokenExpiring,
           let token = connectionContext.transactionToken,
           !token.isExpired {
            LogManager.trace("Implicit OAuth: connection token already refreshed by a concurrent request")

            return token.value
        }

        guard let listener = connectionContext.tokenDelegateListener else {
            LogManager.warning("Implicit OAuth token needs refresh but no token delegate listener is registered")

            throw CXoneChatError.invalidAccessToken
        }

        LogManager.trace("Requesting a fresh implicit connection token from the token delegate")

        // The listener is integrator code — map whatever it throws to the documented
        // ``CXoneChatError/invalidAccessToken`` so provider-specific errors never leak
        // through the SDK's public API (see ``CustomerProvider/setTokenDelegateListener(_:)``).
        let token: OAuthToken
        do {
            token = try await listener(reason)
        } catch {
            error.logError()

            throw CXoneChatError.invalidAccessToken
        }

        connectionContext.connectionToken = token.accessToken
        connectionContext.connectionTokenExpiresAt = token.expiresAt

        // The freshly-delegated token can still be rejected by the backend — surface the documented
        // invalid-token error rather than the raw HTTP failure, so integrators recover via one
        // contract on every entry point (connect and send).
        let value: String
        do {
            value = try await requestAndStoreTransactionToken(for: .oAuthImplicit)
        } catch CXoneChatError.transactionTokenRequestFailed(let statusCode) where statusCode == Self.tokenRejectionStatusCode {
            LogManager.error("Implicit OAuth: the refreshed connection token was rejected (HTTP \(statusCode))")

            throw CXoneChatError.invalidAccessToken
        }

        LogManager.trace("Implicit connection token refreshed successfully")

        return value
    }

    func startAutomatedConnectionFlow() async throws {
        LogManager.trace("Starting automated connection flow")

        connectionContext.chatState = .connected
        broadcaster.send(.chatUpdated(state: connectionContext.chatState, mode: connectionContext.chatMode))
        
        do {
            // Setup websocket event listeners
            if let registerListeners = registerListeners.content {
                registerListeners()
            } else {
                LogManager.error("Unable to register listeners for the socket events")
                
                socketService.disconnect(unexpectedly: true)
                return
            }
            
            guard let threadsService else {
                throw CXoneChatError.invalidParameter("threadService")
            }
            
            try await threadsService.handleForCurrentChatMode(connectionContext.chatMode)
        } catch {
            socketService.disconnect(unexpectedly: true)
            
            throw error
        }
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
                // DeviceFingerprintDTO.init reads UIDevice.current — must run on @MainActor.
                // JSONEncoder.encode and the network fetch are done outside to avoid blocking the main thread.
                let fingerprint = await MainActor.run { DeviceFingerprintDTO(deviceToken: self.connectionContext.deviceToken) }
                var request = URLRequest(url: url, method: .put, contentType: "application/json")
                request.httpBody = try self.encoder.encode(
                    VisitorDTO(
                        customerIdentity: CustomerIdentityDTO(idOnExternalPlatform: customerId),
                        browserFingerprint: fingerprint,
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
                let response = try self.decoder.decode(LiveChatAvailabilityDTO.self, from: data)
                
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
        broadcaster.send(.error(error))
    }

    /// - Throws: ``CXoneChatError/invalidParameter(_:)`` if the socket endpoint URL has not been set properly
    /// - Throws: ``CXoneChatError/notConnected`` if the pulse was not received
    /// - Throws: ``CXoneChatError/invalidAccessToken`` if the OAuth token was rejected or is missing.
    /// - Throws: ``CXoneChatError/missingVisitorId`` if visitor ID is not set.
    /// - Throws: ``CXoneChatError/missingParameter(_:)`` if unable to build the URL.
    /// - Throws: ``CXoneChatError/missingParameter(_:)`` if unable to get cached transaction token.
    /// - Throws: ``CXoneChatError/featureUnavailable(_:)`` if the method is triggered for OAuth explicit authentication type.
    func connectToSocket() async throws {
        LogManager.trace("Connecting to the socket")

        let url = try await buildSocketURL()

        LogManager.trace("Connecting to WebSocket")

        try await socketService.connect(socketURL: url)
    }

    func didCloseConnection(unexpectedly: Bool) {
        LogManager.trace("Websocket connection has been closed")

        connectionContext.chatState = .prepared

        if unexpectedly {
            broadcaster.send(.unexpectedDisconnect)
        } else {
            broadcaster.send(.chatUpdated(state: connectionContext.chatState, mode: connectionContext.chatMode))
        }
    }

    /// - Throws: ``CXoneChatError/missingParameter(_:)`` if a refresh token is not available.
    /// - Throws: ``CXoneChatError/invalidAccessToken`` if the implicit flow has no token delegate listener registered.
    func refreshToken() async throws {
        LogManager.trace("Refreshing a token")

        guard connectionContext.authenticationType == .oAuthImplicit else {
            let entity = try await transactionTokenService.refreshTransactionToken()

            LogManager.trace("Explicit PKCE: transaction token refreshed successfully")

            connectionContext.transactionToken = entity
            return
        }

        try await refreshImplicitConnectionToken(reason: .tokenExpired)
    }

    func reconnect() async throws {
        LogManager.trace("Reconnecting to the web socket")

        try await startAutomatedConnectionFlow()
    }

    func recreateSocketURL(forceRefresh: Bool) async throws -> URL {
        LogManager.trace("Rebuilding socket URL for reconnect (re-minting the transaction token if needed)")

        return try await buildSocketURL(forceRefresh: forceRefresh)
    }
}
