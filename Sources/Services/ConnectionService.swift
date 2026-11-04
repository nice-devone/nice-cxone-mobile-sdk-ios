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
// swiftlint:disable file_length

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

    var connectionContext: ConnectionContext {
        socketService.connectionContext
    }

    private let encoder = JSONEncoder()
    private let decoder = JSONDecoder()
    private let getChannelRetryAttempts: Int

    /// Short-lived cache in front of the channel configuration endpoint, keyed by resolved URL.
    private let channelConfigurationCache: ChannelConfigurationCache
    
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
        retryAttempts: Int = 3,
        channelConfigurationCache: ChannelConfigurationCache = ChannelConfigurationCache()
    ) {
        self.channelConfigurationCache = channelConfigurationCache
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
    /// - Throws: `DecodingError.dataCorrupted` an indication that the data is corrupted or otherwise invalid.
    /// - Throws: `DecodingError.typeMismatch` if the encountered stored value is not a JSON object or otherwise cannot be converted to the required type.
    /// - Throws: `DecodingError.keyNotFound` if the response does not have an entry for the given key.
    /// - Throws: `DecodingError.valueNotFound` if a response has a null value for the given key.
    /// - Throws: `URLError.badServerResponse` if the URL Loading system received bad data from the server.
    /// - Throws: `NSError` object that indicates why the request failed
    func getChannelConfiguration(environment: Environment, brandId: Int, channelId: String) async throws -> ChannelConfiguration {
        LogManager.trace("Getting channel configuration")

        guard let url = environment.chatServerUrl?.channelUrl(brandId: brandId, channelId: channelId) else {
            throw CXoneChatError.channelConfigFailure
        }

        return ChannelConfigurationMapper.map(try await getChannelConfiguration(url: url))
    }
    
    /// - Throws: ``CXoneChatError/channelConfigFailure`` if provided parameters do not create a valid URL.
    /// - Throws: ``CXoneChatError/sdkVersionNotSupported`` if the SDK version is not supported by the server.
    /// - Throws: `DecodingError.dataCorrupted` an indication that the data is corrupted or otherwise invalid.
    /// - Throws: `DecodingError.typeMismatch` if the encountered stored value is not a JSON object or otherwise cannot be converted to the required type.
    /// - Throws: `DecodingError.keyNotFound` if the response does not have an entry for the given key.
    /// - Throws: `DecodingError.valueNotFound` if a response has a null value for the given key.
    /// - Throws: `URLError.badServerResponse` if the URL Loading system received bad data from the server.
    /// - Throws: `NSError` object that indicates why the request failed
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
    /// - Throws: `DecodingError.dataCorrupted` an indication that the data is corrupted or otherwise invalid.
    /// - Throws: `DecodingError.typeMismatch` if the encountered stored value is not a JSON object or otherwise cannot be converted to the required type.
    /// - Throws: `DecodingError.keyNotFound` if the response does not have an entry for the given key.
    /// - Throws: `DecodingError.valueNotFound` if a response has a null value for the given key.
    /// - Throws: `URLError.badServerResponse` if the URL Loading system received bad data from the server.
    /// - Throws: `NSError` object that indicates why the request failed
    /// - Throws: `EncodingError.invalidValue` if a non-conforming floating-point value is encountered during encoding, and the encoding strategy is `.throw`.
    /// - Throws: An error if any value throws an error during encoding.
    func prepare(environment: Environment, brandId: Int, channelId: String) async throws {
        if try isPrepareAlreadyInFlight() {
            return
        }
        
        LogManager.trace("Preparing SDK for connection with default environment")
        
        connectionContext.environment = environment
        
        try await prepare(brandId: brandId, channelId: channelId)
    }

    /// - Throws: ``CXoneChatError/illegalChatState`` if the SDK is not in the required state to trigger the method.
    /// - Throws: ``CXoneChatError/missingParameter(_:)`` if connection`url` is not in correct format.
    /// - Throws: ``CXoneChatError/channelConfigFailure`` if the SDK could not prepare URL for URLRequest
    /// - Throws: `DecodingError.dataCorrupted` an indication that the data is corrupted or otherwise invalid.
    /// - Throws: `DecodingError.typeMismatch` if the encountered stored value is not a JSON object or otherwise cannot be converted to the required type.
    /// - Throws: `DecodingError.keyNotFound` if the response does not have an entry for the given key.
    /// - Throws: `DecodingError.valueNotFound` if a response has a null value for the given key.
    /// - Throws: `URLError.badServerResponse` if the URL Loading system received bad data from the server.
    /// - Throws: `NSError` object that indicates why the request failed
    /// - Throws: `EncodingError.invalidValue` if a non-conforming floating-point value is encountered during encoding, and the encoding strategy is `.throw`.
    /// - Throws: An error if any value throws an error during encoding.
    func prepare(chatURL: String, socketURL: String, loggerURL: String, brandId: Int, channelId: String, tokenURL: String?) async throws {
        // swiftlint:disable:previous function_parameter_count
        if try isPrepareAlreadyInFlight() {
            return
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
    /// - Throws: ``CXoneChatError/invalidAccessToken`` if the OAuth token was rejected or is missing.
    /// - Throws: ``CXoneChatError/invalidRefreshToken(_:)`` if an explicit-PKCE reconnect's refresh-grant recovery
    ///   fails and no further automatic recovery is possible.
    /// - Throws: ``CXoneChatError/invalidData`` when the Data object cannot be successfully converted to a valid UTF-8 string
    /// - Throws: ``CXoneChatError/invalidParameter(_:)`` if the socket endpoint URL has not been set properly
    /// - Throws: ``CXoneChatError/channelConfigFailure`` if the SDK could not prepare URL for URLRequest
    /// - Throws: ``CXoneChatError/notConnected`` if the pulse was not received
    /// - Throws: ``CXoneChatError/missingVisitorId`` if visitor ID is not set.
    /// - Throws: ``CXoneChatError/missingParameter(_:)`` if unable to build the URL.
    /// - Throws: ``CXoneChatError/missingParameter(_:)`` if unable to get cached transaction token.
    /// - Throws: ``CXoneChatError/missingParameter(_:)`` if `setAuthorizationCode(_:)` or `setCodeVerifier(_:)` was not called for the explicit OAuth flow.
    /// - Throws: ``CXoneChatError/transactionTokenRequestFailed(statusCode:)`` if the transaction-token exchange fails.
    /// - Throws: `EncodingError.invalidValue(_:_:)` if the given value is invalid in the current context for this format.
    /// - Throws: `URLError.badServerResponse` if the URL Loading system received bad data from the server.
    /// - Throws: `NSError` object that indicates why the request failed
    func connect() async throws {
        if connectionContext.chatState == .connecting {
            // Calling `connect` in `.connecting` state is ignored
            return
        }
        if connectionContext.chatState.isChatAvailable {
            broadcaster.send(connectionContext.chatUpdatedEvent)
            return
        }
        
        guard connectionContext.chatState == .prepared else {
            throw CXoneChatError.illegalChatState
        }

        // Captured before the first `await` below. If `signOut()` clears the session while this call
        // is suspended, `sessionGeneration` no longer matches and the mismatch checks that follow stop
        // this call from opening or advancing a connection for a session that no longer exists.
        let generation = connectionContext.sessionGeneration

        // `isLiveChatAvailable()` alone can await a network round-trip, so the mismatch must be checked
        // against the whole condition before branching — checking inside only one branch (as a guard
        // placed after the `{` below once was) leaves the other branch, taken just as often, unchecked.
        let isOffline: Bool
        if connectionContext.chatMode == .liveChat {
            isOffline = try await !isLiveChatAvailable()
        } else {
            isOffline = false
        }

        guard !sessionChanged(since: generation) else {
            throw CXoneChatError.illegalChatState
        }

        if isOffline {
            LogManager.trace("Chat mode is live chat but the chat is offline")

            connectionContext.chatState = .offline
            broadcaster.send(connectionContext.chatUpdatedEvent)
        } else {
            try await openConnection(since: generation)
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
    /// - Throws: `EncodingError.invalidValue(_:_:)` if the given value is invalid in the current context for this format.
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
        LogManager.trace("Signing out a user")

        // `disconnect(unexpectedly:)` calls `didCloseConnection` synchronously as its first statement,
        // and that method short-circuits on `chatState == .initial` (added earlier in this PR so a
        // late socket close can't resurrect `.prepared` after a sign-out). Without this write first,
        // `chatState` here still holds whatever the live session had — `.ready` or `.prepared` — so the
        // short-circuit never fires: `didCloseConnection` writes `.prepared` and broadcasts
        // `.chatUpdated(state: .prepared)` before `clear()` a few lines down corrects the state to
        // `.initial`. The final state is right either way, but that broadcast becomes the last event a
        // subscriber sees, contradicting the very `.initial` contract this PR documents for `signOut()`.
        connectionContext.chatState = .initial

        socketService.disconnect(unexpectedly: false)

        channelConfigurationCache.invalidate()

        // Redundant for `chatState` (just written above) but still does the rest of the reset — bumping
        // `sessionGeneration` as its first statement, which is why it runs before the two
        // `clearStoredData()` calls below: that narrows the window in which an in-flight `prepare(...)`/
        // `connect()` could still observe the pre-sign-out generation, pass its `sessionChanged(since:)`
        // check, and repopulate what these are about to empty. Neither call reads `connectionContext`.
        connectionContext.clear()

        // The session outlives `connectionContext` alone: the thread list still holds the signed-out
        // customer's conversations (and, through them, their messages and per-contact custom fields),
        // and the customer custom fields persist across every thread. `signOut()` documents the
        // instance as reusable, so without this an integrator that signs out and presents the chat
        // UI again on the same instance surfaces the previous customer's data.
        threadsService?.clearStoredData()
        customerFieldsService?.clearStoredData()

        broadcaster.invalidate()
    }
}

// MARK: - Private methods

private extension ConnectionService {

    /// - Returns: `true` if a prepare is already running, so the caller has nothing to do.
    /// - Throws: ``CXoneChatError/illegalChatState`` if the SDK is not in a state from which it can be prepared.
    func isPrepareAlreadyInFlight() throws -> Bool {
        if connectionContext.chatState == .preparing {
            return true
        }
        guard connectionContext.chatState.isPrepareable else {
            throw CXoneChatError.illegalChatState
        }

        return false
    }

    /// Whether `connectionContext.clear()` has run since `generation` was captured — i.e. `signOut()`
    /// ended the session while the caller was suspended on an `await`.
    func sessionChanged(since generation: Int) -> Bool {
        connectionContext.sessionGeneration != generation
    }

    /// Opens the WebSocket connection and runs the automated connection flow for `connect()`, undoing
    /// whatever lands after `signOut()` ended the session captured as `generation` mid-flight.
    ///
    /// - Throws: ``CXoneChatError/illegalChatState`` if `signOut()` ended the session while connecting.
    /// - Throws: Any error thrown while connecting to the socket or running the automated connection flow.
    func openConnection(since generation: Int) async throws {
        LogManager.trace("Setting `state` to `connecting` and connecting to the CXone service")

        connectionContext.chatState = .connecting
        broadcaster.send(connectionContext.chatUpdatedEvent)

        do {
            try await connectToSocket()
        } catch {
            // Any failure while connecting (token refresh, transaction-token exchange, or the WebSocket
            // handshake itself) must reset the state machine to `.prepared`, or the `.prepared` guard
            // in `connect()` rejects every subsequent `connect()` and the SDK is stranded at `.connecting`.
            //
            // Unless sign-out already moved the session on. `chatState` is written to `.connecting` a
            // few lines up with no `await` before it, so — despite `clear()` having already set it to
            // `.initial` in the ordering this normally runs in — a `signOut()` landing in that narrow
            // window leaves it at `.connecting` instead: set it back explicitly rather than assume.
            // `.connecting` is outside `isPrepareable`, so leaving it in place stops `prepare()` from
            // ever recovering the instance `signOut()` documents as reusable. The token exchange may
            // also have run to completion before the handshake itself failed, so its residue needs the
            // same cleanup as the success path below.
            if !sessionChanged(since: generation) {
                connectionContext.chatState = .prepared
            } else {
                connectionContext.chatState = .initial
                clearTokenExchangeResidue()
            }

            throw error
        }

        // Deliberately outside the `do`/`catch` above: a `throw` here must propagate to this
        // method's caller, not be re-caught by that `catch` and run its residue cleanup a second time.
        guard !sessionChanged(since: generation) else {
            // Sign-out ran while the handshake for the previous session was still in flight; the
            // socket that just connected authenticates an identity that no longer exists.
            //
            // `chatState` is written back to `.initial` *before* `disconnect()` rather than assume
            // `clear()`'s write survived (see the `catch` above for why that assumption can be
            // wrong) — and the ordering matters here: `SocketServiceImpl.disconnect(unexpectedly:)`
            // calls `didCloseConnection` synchronously as its first statement, and that method
            // short-circuits on `chatState == .initial`. Writing `.initial` first means it does;
            // written after, `didCloseConnection` would still see the stale `.connecting` from the
            // race this arm handles, overwrite it with `.prepared`, and broadcast that state to
            // integrators before this line silently corrected it — the final state is right either
            // way, but the broadcast would say otherwise.
            connectionContext.chatState = .initial
            socketService.disconnect(unexpectedly: false)
            clearTokenExchangeResidue()

            throw CXoneChatError.illegalChatState
        }

        try await startAutomatedConnectionFlow()

        guard !sessionChanged(since: generation) else {
            // Sign-out ran while the thread-recovery flow above was still in flight. Its recovery
            // handlers write `chatState = .ready`, repopulate the thread list, restore customer
            // custom fields, and set `contactId` — all landing after `clear()`'s reset — so undoing
            // them here mirrors the exact set of calls `signOut()` itself makes.
            //
            // This scrub assumes the context is still in the post-`clear()` quiescent state, which
            // is usually true (`signOut()` disconnects the socket first, so reaching here needs the
            // flow's awaited events to have already resolved pre-disconnect) but not guaranteed: if
            // the integrator has already reused this instance — signOut() explicitly documents it as
            // reusable — and a new prepare()/connect() legitimately advanced the session by the time
            // this resumes, these writes land on that new session instead. Accepted as the lesser
            // evil against unconditionally leaking the previous customer's threads and fields.
            connectionContext.chatState = .initial
            connectionContext.contactId = nil
            threadsService?.clearStoredData()
            customerFieldsService?.clearStoredData()

            throw CXoneChatError.illegalChatState
        }
    }

    /// Resets what the token exchange inside `connectToSocket()` may have written into the context
    /// after a mid-flight `signOut()` already purged it. `transactionToken` and `customer` are
    /// keychain-backed, so leaving them in place would hand the next customer on this instance the
    /// previous one's identity — surviving even a process restart, unlike every other residue this
    /// guard family cleans up. Purging the keychain here (rather than assigning `nil`, which would only
    /// overwrite the entries with an undecodable `null` blob) actually removes them, the same way
    /// `clear()` itself does. `connectionToken`/`connectionTokenExpiresAt` are the equivalent for the
    /// implicit-OAuth flow, in-memory only.
    ///
    /// Like the thread-recovery rollback above, this assumes the context is still in the post-`clear()`
    /// quiescent state: if the integrator already reused the instance and a new `prepare()`/`connect()`
    /// legitimately advanced the session by the time this resumes, these writes land on that new session
    /// instead. Accepted for the same reason — the alternative is leaving the previous customer's
    /// keychain identity in place, which is worse.
    func clearTokenExchangeResidue() {
        connectionContext.keychainService.purge()
        connectionContext.connectionToken = nil
        connectionContext.connectionTokenExpiresAt = nil
    }

    /// - Throws: ``CXoneChatError/sdkVersionNotSupported`` if the SDK version is not supported by the server.
    /// - Throws: `DecodingError.dataCorrupted` an indication that the data is corrupted or otherwise invalid.
    /// - Throws: `DecodingError.typeMismatch` if the encountered stored value is not a JSON object or otherwise cannot be converted to the required type.
    /// - Throws: `DecodingError.keyNotFound` if the response does not have an entry for the given key.
    /// - Throws: `DecodingError.valueNotFound` if a response has a null value for the given key.
    /// - Throws: `URLError.badServerResponse` if the URL Loading system received bad data from the server.
    /// - Throws: `NSError` object that indicates why the request failed
    func getChannelConfiguration(url: URL) async throws -> ChannelConfigurationDTO {
        // Captured before the cache-hit check, not just before the fetch: a `signOut()` landing in
        // the gap between a miss and reading the generation would otherwise be read as the new
        // (post-invalidation) generation, letting the eventual store below through regardless.
        // Capturing it first guarantees any invalidation from this point on is caught.
        let generation = channelConfigurationCache.currentGeneration()

        if let cached = channelConfigurationCache.get(for: url) {
            LogManager.trace("Using cached channel configuration")

            return cached
        }

        let configuration = try await Task
            .retrying(attempts: getChannelRetryAttempts) {
                let (data, _) = try await self.connectionContext.session.fetch(from: url)

                return try self.decoder.decode(ChannelConfigurationDTO.self, from: data)
            }
            .value

        // Deliberately the freshly decoded value, never `connectionContext.channelConfig` — the latter
        // carries an overlaid live-chat availability whose own 60s TTL would be stretched to this cache's.
        channelConfigurationCache.set(configuration, for: url, generation: generation)

        return configuration
    }

    /// - Throws: ``CXoneChatError/missingParameter(_:)`` if connection`url` is not in correct format.
    /// - Throws: ``CXoneChatError/channelConfigFailure`` if the SDK could not prepare URL for URLRequest
    /// - Throws: `DecodingError.dataCorrupted` an indication that the data is corrupted or otherwise invalid.
    /// - Throws: `DecodingError.typeMismatch` if the encountered stored value is not a JSON object or otherwise cannot be converted to the required type.
    /// - Throws: `DecodingError.keyNotFound` if the response does not have an entry for the given key.
    /// - Throws: `DecodingError.valueNotFound` if a response has a null value for the given key.
    /// - Throws: `URLError.badServerResponse` if the URL Loading system received bad data from the server.
    /// - Throws: `NSError` object that indicates why the request failed
    /// - Throws: `EncodingError.invalidValue` if a non-conforming floating-point value is encountered during encoding, and the encoding strategy is `.throw`.
    /// - Throws: An error if any value throws an error during encoding.
    func prepare(brandId: Int, channelId: String) async throws {
        LogManager.trace("Changing state to `preparing` and setting channel configuration to the brand: \(brandId) and channel: \(channelId)")

        connectionContext.chatState = .preparing

        // Captured before the first `await` below. If `signOut()` clears the session while this call
        // is suspended, `sessionGeneration` no longer matches and the mismatch checks that follow stop
        // this call from writing the previous session's data into the one that just replaced it.
        let generation = connectionContext.sessionGeneration

        guard let url = connectionContext.environment.chatServerUrl?.channelUrl(brandId: brandId, channelId: channelId) else {
            connectionContext.chatState = .initial
            throw CXoneChatError.missingParameter("url")
        }

        do {
            let channelConfig = try await getChannelConfiguration(url: url)

            guard !sessionChanged(since: generation) else {
                throw CXoneChatError.illegalChatState
            }

            connectionContext.channelConfig = channelConfig
            connectionContext.brandId = brandId
            connectionContext.channelId = channelId

            // Configure the client logger since all necessary parameters are set
            await LogManager.configureInternalLogger(connectionContext: connectionContext)

            guard !sessionChanged(since: generation) else {
                throw CXoneChatError.illegalChatState
            }

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

            guard !sessionChanged(since: generation) else {
                throw CXoneChatError.illegalChatState
            }

            connectionContext.chatState = .prepared

            broadcaster.send(connectionContext.chatUpdatedEvent)
        } catch {
            if !sessionChanged(since: generation) {
                connectionContext.chatState = .initial
            }
            
            throw error
        }
    }
    
    /// - Parameter forceRefresh: When `true`, bypass the local-expiry cache and mint a fresh transaction
    ///   token even if the cached one is still valid by the device clock. Used by the reconnect path
    ///   (``recreateSocketURL(forceRefresh:)``) to recover from a server-side token invalidation the local
    ///   expiry check cannot see. Skipped only for the explicit flow's first exchange, which needs a fresh
    ///   authorization code the SDK cannot obtain silently — an explicit reconnect mints through the
    ///   implicit endpoint instead and can force-mint like any other type.
    /// - Throws: ``CXoneChatError/missingVisitorId`` if visitor ID is not set.
    /// - Throws: ``CXoneChatError/missingParameter(_:)`` if unable to build the URL.
    /// - Throws: ``CXoneChatError/missingParameter(_:)`` if unable to get cached transaction token.
    /// - Throws: ``CXoneChatError/invalidAccessToken`` if the OAuth token was rejected by the backend.
    /// - Throws: ``CXoneChatError/invalidRefreshToken(_:)`` if a rejected stored access token on an explicit-PKCE
    ///   reconnect has no stored refresh token to recover with, or the refresh-grant recovery itself fails.
    /// - Throws: ``CXoneChatError/transactionTokenRequestFailed(statusCode:)`` if the transaction-token
    ///   exchange fails with a non-2xx response, and for a refused credential on an authentication type
    ///   with no recovery path — anonymous, secured-cookie, and the explicit flow's first exchange, which
    ///   needs an authorization code the SDK cannot obtain silently. A refusal on an explicit-PKCE
    ///   reconnect starts refresh-grant recovery instead, and on the implicit flow a delegate refresh;
    ///   both branch on ``TransactionTokenService``'s classification of the response, never on the status.
    func getAndStoreTransactionTokenIfNeeded(for authenticationType: AuthenticationTypeDTO, forceRefresh: Bool = false) async throws -> String {
        // On reconnect the server may have invalidated a token that is still valid by the device clock.
        // Bypass the local-expiry cache so a fresh token is minted instead of the rejected one being replayed.
        // Skipped only for the explicit flow's first exchange: it needs a fresh authorization code the SDK
        // cannot obtain silently, so it must fall through to the re-auth path rather than force-mint. An
        // explicit reconnect no longer needs that code — it mints through the implicit endpoint below — so
        // it can force-mint like any other type.
        let isExplicitFirstExchange = authenticationType == .oAuthExplicit && !connectionContext.isExplicitOAuthReconnect
        let shouldForceMint = forceRefresh && !isExplicitFirstExchange

        // The cached transaction token's own expiry can outlast the explicit-PKCE access token nested inside
        // it — the two are minted with independent TTLs. Reusing it in that window connects successfully but
        // leaves every per-event exchange holding a dead access token, surfacing later as a decode/format
        // error and an unexpected disconnect rather than a clean refresh. Route to the case 2/3 handling below
        // instead of the plain cache hit whenever that access token has already expired.
        let hasExpiredExplicitAccessToken = connectionContext.isExplicitOAuthReconnect
            && connectionContext.isExplicitAccessTokenExpired

        if !shouldForceMint, !hasExpiredExplicitAccessToken, let token = connectionContext.reusableTransactionToken {
            LogManager.info("Cached transaction token is still valid")

            return token.value
        }

        // Case 3, known upfront: the stored access token is already expired by the device clock. Skip
        // straight to the refresh-grant sequence rather than spending a round-trip on an implicit-endpoint
        // exchange that a locally-expired token cannot succeed against. This trigger is purely local, so it
        // holds whatever status the backend would have answered with (unlike the catch below, which still
        // exists for the "looked valid but was rejected anyway" case).
        if hasExpiredExplicitAccessToken, connectionContext.hasStoredRefreshToken {
            return try await recoverExplicitSessionViaRefreshGrant()
        }

        // Explicit-PKCE reconnect (case 2/3 of the token-expiry model): never replay the single-use
        // authorization_code exchange. Route through the implicit-endpoint mechanism instead, reusing the
        // stored explicit access token — see `TransactionTokenService`'s `.oAuthImplicit` request builder.
        let requestType: AuthenticationTypeDTO = connectionContext.isExplicitOAuthReconnect ? .oAuthImplicit : authenticationType

        do {
            LogManager.trace("Transaction token is not available or expired, requesting a new one")

            return try await requestAndStoreTransactionToken(for: requestType)
        } catch let rejection as TokenRejectionError where connectionContext.isExplicitOAuthReconnect {
            // Explicit-PKCE reconnect: the stored access token was rejected — either it was already
            // expired (case 3 of the token-expiry model), or it looked locally valid but the backend
            // disagreed (revoked elsewhere, session invalidated, clock skew). Either way, a stored refresh
            // token can still recover the session — fall through to the refresh-grant sequence instead of
            // dead-ending, rather than forcing a full re-login the refresh token could have avoided.
            guard connectionContext.hasStoredRefreshToken else {
                LogManager.warning("Explicit OAuth: stored access token rejected on reconnect (\(rejection.logDescription)), no refresh token available")

                // No message to carry: the backend rejected the *access* token, and the reason the session
                // cannot be recovered is local — there is no refresh token stored to spend.
                throw CXoneChatError.invalidRefreshToken(nil)
            }

            LogManager.warning("Explicit OAuth: access token rejected on reconnect (\(rejection.logDescription)) -> attempting refresh-grant recovery")

            return try await recoverExplicitSessionViaRefreshGrant()
        } catch let rejection as TokenRejectionError where authenticationType == .oAuthImplicit {
            // Implicit OAuth: the backend rejected the connection token even though it hadn't timed out.
            // With a listener, ask for a fresh token and retry the exchange once; without one there is
            // nothing to refresh with, so surface the documented invalid-token error either way rather
            // than leaking the raw HTTP failure (keeps the connect path consistent with the send path).
            guard connectionContext.tokenDelegateListener != nil else {
                LogManager.warning("Implicit OAuth: connection token rejected (\(rejection.logDescription)) and no token delegate listener is registered")

                throw CXoneChatError.invalidAccessToken
            }

            LogManager.trace("Implicit OAuth: connection token rejected (\(rejection.logDescription)) — refreshing via delegate and retrying")

            return try await refreshImplicitConnectionToken(reason: .tokenInvalid)
        } catch let rejection as TokenRejectionError {
            // Anonymous, secured-cookie, and the explicit flow's first exchange: nothing to recover with,
            // so the refusal surfaces as the raw exchange failure. Mapped rather than rethrown because
            // `TokenRejectionError` is internal and must not reach an integrator.
            LogManager.error("Transaction token request rejected (\(rejection.logDescription))")

            throw CXoneChatError.transactionTokenRequestFailed(statusCode: rejection.statusCode)
        } catch {
            error.logError()

            throw error
        }
    }

    /// Requests a transaction token for `authenticationType`, stores it, and refreshes the cached customer identity.
    func requestAndStoreTransactionToken(for authenticationType: AuthenticationTypeDTO) async throws -> String {
        let entity = try await transactionTokenService.requestTransactionToken(for: authenticationType)

        // The implicit endpoint's response carries no `thirdParty` block, so an explicit-PKCE reconnect
        // would otherwise drop the access token it just authenticated with here — and every subsequent
        // reconnect, message send, and refresh depends on it being present. Carry the stored one forward
        // when the new response doesn't carry its own, and merge (rather than replace wholesale) when it
        // does — a response with an access token but no refresh token would otherwise discard the refresh
        // token `refreshExplicitAccessTokenAndTransactionToken` just took care to preserve one hop earlier.
        if let freshAccessToken = entity.accessToken {
            connectionContext.transactionToken = entity.copy(
                accessToken: AccessTokenDTO.merging(cached: connectionContext.transactionToken?.accessToken, fresh: freshAccessToken)
            )
        } else if let previousAccessToken = connectionContext.transactionToken?.accessToken {
            connectionContext.transactionToken = entity.copy(accessToken: previousAccessToken)
        } else {
            connectionContext.transactionToken = entity
        }

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
    ///   cannot see. Skipped only for the explicit flow's first exchange, which needs a fresh authorization
    ///   code the SDK cannot obtain silently — an explicit reconnect mints through the implicit endpoint and
    ///   honors this flag like any other type. The initial connect leaves this at its default (`false`).
    /// - Throws: ``CXoneChatError/transactionTokenRequestFailed(statusCode:)`` if the transaction-token exchange fails.
    /// - Throws: ``CXoneChatError/invalidParameter(_:)`` if the socket endpoint URL cannot be built.
    /// - Throws: ``CXoneChatError/invalidAccessToken`` if the OAuth token was rejected or is missing.
    /// - Throws: ``CXoneChatError/invalidRefreshToken(_:)`` if an explicit-PKCE reconnect's refresh-grant recovery
    ///   fails and no further automatic recovery is possible.
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

    /// Explicit-PKCE case 3 of the token-expiry model: transaction token and OAuth access token both
    /// expired (or the access token was rejected), refresh token still valid.
    ///
    /// Two-hop sequence: spend the refresh token for a fresh access token, then trade that access token
    /// for a new transaction token via the implicit-grant endpoint — the refresh-grant response carries
    /// no transaction token of its own. Shared by both the proactive refresh (``refreshToken()``, driven by
    /// ``ConnectionContext/needsProactiveTokenRefresh``) and the reactive reconnect fallback in
    /// ``getAndStoreTransactionTokenIfNeeded(for:forceRefresh:)`` — a single site to persist the merged
    /// access/refresh token correctly, rather than two independent ones that can drift out of sync.
    ///
    /// - Throws: ``CXoneChatError/missingParameter(_:)`` if no transaction token is cached to attach the
    ///   refreshed access token to, no refresh token is stored, or the refresh-grant response omitted a
    ///   new access token.
    /// - Throws: ``CXoneChatError/invalidRefreshToken(_:)`` if the backend rejected the refresh grant,
    ///   carrying its own description of the rejection when it supplied one.
    /// - Throws: ``CXoneChatError/transactionTokenRequestFailed(statusCode:)`` if either hop fails with any
    ///   other non-2xx response.
    func refreshExplicitAccessTokenAndTransactionToken() async throws -> String {
        // Single-flighted for the same reason as the implicit path (`refreshImplicitConnectionToken`):
        // the authorization server may rotate the refresh token on each grant (RFC 6749 §6), so two
        // concurrent callers spending the same stored one could have the loser replay a consumed token.
        try await tokenRefreshCoordinator.refresh {
            try await self.performExplicitAccessTokenRefreshAndExchange()
        }
    }

    /// Shared by every explicit refresh-grant recovery site — the two reconnect paths in
    /// ``getAndStoreTransactionTokenIfNeeded(for:forceRefresh:)`` (the locally-expired short-circuit and the
    /// reactive-rejection fallback) and the proactive ``refreshToken()`` — so none of them can silently diverge
    /// on what an integrator sees for the same underlying failure. Always coalesces with an in-flight refresh
    /// (never forces): every caller runs the identical two-hop sequence and always produces a fresh, valid
    /// result, so there is nothing stale to avoid inheriting — unlike the implicit path, where a forced
    /// (reactive) refresh must not join an in-flight proactive one that may be re-delegating the very token
    /// the backend just rejected. Joining here is what prevents concurrent callers from independently spending
    /// the same stored refresh token, which — since the authorization server may rotate it on each grant
    /// (RFC 6749 §6) — could have the loser replay an already-consumed one.
    ///
    /// Only outcomes that mean the session cannot be recovered map to ``CXoneChatError/invalidRefreshToken(_:)``:
    /// a refusal of the stored refresh token itself (matching `performImplicitTokenRefresh`'s pattern —
    /// a transient network/decode failure must not be conflated with "re-authenticate," or a temporary blip
    /// forces an unnecessary full re-login; a refusal of the *access* token minted by the second hop is
    /// deliberately excluded below, since it leaves the refresh token alive), a 2xx refresh-grant response
    /// that omits the access token (the backend's own
    /// response was incomplete; there is nothing further to retry), and no stored refresh token to spend in
    /// the first place (`refresh_token` is optional in an OAuth response — RFC 6749 §5.1 — so a session can
    /// reach here without ever having received one). Every one of these means the session could not be
    /// recovered automatically — case 4 of the token-expiry model, where the app must re-authenticate.
    /// - Throws: ``CXoneChatError/invalidRefreshToken(_:)`` if the refresh grant was rejected by the backend, its
    ///   2xx response omitted the access token, or no refresh token was stored to attempt the grant with.
    func recoverExplicitSessionViaRefreshGrant() async throws -> String {
        do {
            return try await refreshExplicitAccessTokenAndTransactionToken()
        } catch CXoneChatError.missingParameter(let parameter) where parameter == "accessToken" || parameter == "refreshToken" {
            LogManager.warning("Explicit OAuth: refresh-grant recovery could not proceed (missing \(parameter))")

            // Local outcomes, so there is no backend message to attach: either nothing was stored to spend,
            // or the grant succeeded but answered without a new access token.
            throw CXoneChatError.invalidRefreshToken(nil)
        }

        // A rejected grant already arrives as `invalidRefreshToken`, thrown by `TransactionTokenService`
        // where the response body — and so the backend's description of the rejection — is still in scope.
        // It propagates untouched; re-mapping it here would only discard that message.
    }

    func performExplicitAccessTokenRefreshAndExchange() async throws -> String {
        guard let cachedTransactionToken = connectionContext.transactionToken else {
            throw CXoneChatError.missingParameter("transactionToken")
        }

        let refreshedAccessToken = try await transactionTokenService.requestAccessTokenRefresh()
        let mergedAccessToken = AccessTokenDTO.merging(cached: cachedTransactionToken.accessToken, fresh: refreshedAccessToken)

        LogManager.trace("Explicit PKCE: access token refreshed successfully, exchanging it for a new transaction token")

        // Stash the merged access token so `.oAuthImplicit`'s request builder (which falls back to it
        // when there's no integrator JWT) picks it up, and so `requestAndStoreTransactionToken`'s existing
        // carry-forward logic preserves it if the implicit endpoint's response omits `thirdParty`.
        connectionContext.transactionToken = cachedTransactionToken.copy(accessToken: mergedAccessToken)

        do {
            return try await requestAndStoreTransactionToken(for: .oAuthImplicit)
        } catch let rejection as TokenRejectionError {
            // The refresh grant succeeded, so the refresh token is alive; it is the freshly-minted access
            // token that this second hop refused. That is not case 4 — re-authenticating would not help —
            // so it stays the raw exchange failure rather than becoming `invalidRefreshToken`.
            LogManager.error("Explicit OAuth: the refreshed access token was rejected by the implicit-grant exchange (\(rejection.logDescription))")

            throw CXoneChatError.transactionTokenRequestFailed(statusCode: rejection.statusCode)
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
           let token = connectionContext.reusableTransactionToken {
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
        } catch let rejection as TokenRejectionError {
            LogManager.error("Implicit OAuth: the refreshed connection token was rejected (\(rejection.logDescription))")

            throw CXoneChatError.invalidAccessToken
        }

        LogManager.trace("Implicit connection token refreshed successfully")

        return value
    }

    func startAutomatedConnectionFlow() async throws {
        LogManager.trace("Starting automated connection flow")

        connectionContext.chatState = .connected
        broadcaster.send(connectionContext.chatUpdatedEvent)
        
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
    /// - Throws: `URLError.badServerResponse` if the URL Loading system received bad data from the server.
    /// - Throws: `NSError` object that indicates why the request failed
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
    /// - Throws: `URLError.badServerResponse` if the URL Loading system received bad data from the server.
    /// - Throws: `NSError` object that indicates why the request failed
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
    /// - Throws: ``CXoneChatError/invalidRefreshToken(_:)`` if an explicit-PKCE reconnect's refresh-grant recovery
    ///   fails and no further automatic recovery is possible.
    /// - Throws: ``CXoneChatError/missingVisitorId`` if visitor ID is not set.
    /// - Throws: ``CXoneChatError/missingParameter(_:)`` if unable to build the URL.
    /// - Throws: ``CXoneChatError/missingParameter(_:)`` if unable to get cached transaction token.
    /// - Throws: ``CXoneChatError/transactionTokenRequestFailed(statusCode:)`` if the transaction-token exchange fails.
    func connectToSocket() async throws {
        LogManager.trace("Connecting to the socket")

        let url = try await buildSocketURL()

        LogManager.trace("Connecting to WebSocket")

        try await socketService.connect(socketURL: url)
    }

    func didCloseConnection(unexpectedly: Bool) {
        // `.initial` means `signOut()` already ended this session; a socket from before that could
        // still close afterward (e.g. failing the in-flight thread-list fetch once its connection is
        // torn down) and this notification arrives after the fact. It must not resurrect `.prepared`
        // onto a session that no longer exists.
        guard connectionContext.chatState != .initial else {
            LogManager.trace("Ignoring socket close for a session that has already been signed out")
            return
        }

        LogManager.trace("Websocket connection has been closed")

        connectionContext.chatState = .prepared

        if unexpectedly {
            broadcaster.send(.unexpectedDisconnect)
        } else {
            broadcaster.send(connectionContext.chatUpdatedEvent)
        }
    }

    /// - Throws: ``CXoneChatError/missingParameter(_:)`` if no transaction token is cached to refresh against.
    /// - Throws: ``CXoneChatError/invalidAccessToken`` if the implicit flow has no token delegate listener
    ///   registered.
    /// - Throws: ``CXoneChatError/invalidRefreshToken(_:)`` if the explicit flow's refresh grant was rejected,
    ///   returned no access token, or had no stored refresh token to spend.
    func refreshToken() async throws {
        LogManager.trace("Refreshing a token")

        guard connectionContext.authenticationType == .oAuthImplicit else {
            _ = try await recoverExplicitSessionViaRefreshGrant()
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
