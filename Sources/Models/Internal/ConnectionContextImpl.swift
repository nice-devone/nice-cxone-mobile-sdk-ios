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

final class ConnectionContextImpl: ConnectionContext {

    // MARK: - Properties

    let keychainService: any KeychainStorage
    let userDefaultsService: UserDefaultsService
    /// An object that coordinates a group of related, network data transfer tasks.
    let session: URLSessionProtocol

    private let _deviceToken: SafeAccessContainer<String?>
    private let _authorizationCode: SafeAccessContainer<String>
    private let _codeVerifier: SafeAccessContainer<String>
    private let _connectionToken: SafeAccessContainer<String?>
    private let _connectionTokenExpiresAt: SafeAccessContainer<Date?>
    private let _tokenDelegateListener: SafeAccessContainer<TokenDelegateListener?>
    private let _contactId: SafeAccessContainer<String?>
    private let _channelConfig: SafeAccessContainer<ChannelConfigurationDTO>
    private let _brandId: SafeAccessContainer<Int>
    private let _channelId: SafeAccessContainer<String>
    private let _destinationId: SafeAccessContainer<String>
    private let _environment: SafeAccessContainer<EnvironmentDetails>
    private let _persistedSetPositionInQueueEvent: SafeAccessContainer<SetPositionInQueueEventDTO?>
    private let _lastPageViewed: SafeAccessContainer<PageViewEventDTO?>
    private let _chatState: SafeAccessContainer<ChatState>
    private let _visitDetailsStore: SafeAccessContainer<CurrentVisitDetails?>
    private let _sessionGeneration: SafeAccessContainer<Int>

    // MARK: - Computed Properties

    /// The token of the device for push notifications.
    var deviceToken: String? {
        get { _deviceToken.content }
        set {
            _deviceToken.mutate { content in
                content = newValue
            }
        }
    }
    /// The code used for login with OAuth.
    var authorizationCode: String {
        get { _authorizationCode.content }
        set {
            _authorizationCode.mutate { content in
                content = newValue
            }
        }
    }
    /// The code verifier used for OAuth (if PKCE is required).
    var codeVerifier: String {
        get { _codeVerifier.content }
        set {
            _codeVerifier.mutate { content in
                content = newValue
            }
        }
    }

    /// The JWT access token provided by the integrator for implicit OAuth flow. In-memory only — not Keychain-backed.
    var connectionToken: String? {
        get { _connectionToken.content }
        set {
            _connectionToken.mutate { content in
                content = newValue
            }
        }
    }

    /// The absolute expiry of ``connectionToken`` for the implicit OAuth flow, or `nil` if none is set. In-memory only.
    var connectionTokenExpiresAt: Date? {
        get { _connectionTokenExpiresAt.content }
        set {
            _connectionTokenExpiresAt.mutate { content in
                content = newValue
            }
        }
    }

    /// Listener invoked to obtain a fresh connection token for the implicit OAuth flow, or `nil` if not registered. In-memory only.
    var tokenDelegateListener: TokenDelegateListener? {
        get { _tokenDelegateListener.content }
        set {
            _tokenDelegateListener.mutate { content in
                content = newValue
            }
        }
    }

    /// The unique contact id for the last loaded thread.
    var contactId: String? {
        get { _contactId.content }
        set {
            _contactId.mutate { content in
                content = newValue
            }
        }
    }
    /// The current channel configuration for currently connected CXone session.
    var channelConfig: ChannelConfigurationDTO {
        get { _channelConfig.content }
        set {
            _channelConfig.mutate { content in
                content = newValue
            }
        }
    }
    /// The id of the brand for the chat.
    var brandId: Int {
        get { _brandId.content }
        set {
            _brandId.mutate { content in
                content = newValue
            }
        }
    }
    /// The id of the channel for the chat.
    var channelId: String {
        get { _channelId.content }
        set {
            _channelId.mutate { content in
                content = newValue
            }
        }
    }
    /// The id generated for the destination.
    var destinationId: String {
        get { _destinationId.content }
        set {
            _destinationId.mutate { content in
                content = newValue
            }
        }
    }
    /// The environment/location to use for CXone.
    var environment: EnvironmentDetails {
        get { _environment.content }
        set {
            _environment.mutate { content in
                content = newValue
            }
        }
    }
    var persistedSetPositionInQueueEvent: SetPositionInQueueEventDTO? {
        get { _persistedSetPositionInQueueEvent.content }
        set {
            _persistedSetPositionInQueueEvent.mutate { content in
                content = newValue
            }
        }
    }
    var lastPageViewed: PageViewEventDTO? {
        get { _lastPageViewed.content }
        set {
            _lastPageViewed.mutate { content in
                content = newValue
            }
        }
    }
    /// Current chat state of the SDK
    ///
    /// The state defines whether it is necessary to set up the SDK, connect to the CXone services or start communication with an agent.
    var chatState: ChatState {
        get { _chatState.content }
        set {
            _chatState.mutate { content in
                content = newValue
            }
        }
    }

    /// Identifies the current session; incremented every time ``clear()`` runs.
    var sessionGeneration: Int {
        _sessionGeneration.content
    }

    nonisolated var visitorId: String? {
        get { userDefaultsService.get(String.self, for: .visitorId) }
        set { userDefaultsService.set(newValue, for: .visitorId) }
    }
    nonisolated var visitDetails: CurrentVisitDetails? {
        get {
            if let cached = _visitDetailsStore.content {
                return cached
            }
            
            let stored = userDefaultsService.get(CurrentVisitDetails.self, for: .visitDetails)
            _visitDetailsStore.mutate { store in
                store = stored
            }
            
            return stored
        }
        set {
            _visitDetailsStore.mutate { store in
                guard store != newValue else {
                    return
                }

                store = newValue
                userDefaultsService.set(newValue, for: .visitDetails)
            }
        }
    }
    nonisolated var customer: CustomerIdentityDTO? {
        get { keychainService.get(CustomerIdentityDTO.self, for: .customer) }
        set { keychainService.set(newValue, for: .customer) }
    }
    /// The current transaction token for WebSocket authentication. Has a short lifetime (~10 minutes).
    nonisolated var transactionToken: TransactionTokenDTO? {
        get { keychainService.get(TransactionTokenDTO.self, for: .transactionToken) }
        set { keychainService.set(newValue, for: .transactionToken) }
    }

    // MARK: - Static Properties

    /// The channel configuration a context starts with, and returns to on ``clear()``.
    static let defaultChannelConfig = ChannelConfigurationDTO(
        settings: ChannelSettingsDTO(
            hasMultipleThreadsPerEndUser: false,
            isProactiveChatEnabled: false,
            isSendTranscriptEnabled: false,
            fileRestrictions: FileRestrictionsDTO(
                allowedFileSize: 40,
                allowedFileTypes: [],
                isAttachmentsEnabled: false
            ),
            features: [:]
        ),
        isAuthorizationEnabled: false,
        prechatSurvey: nil,
        liveChatAvailability: CurrentLiveChatAvailability(isChannelLiveChat: false, isOnline: false, expires: .distantPast),
        authenticationType: .anonymous
    )

    /// The environment a context starts with, and returns to on ``clear()``.
    static let defaultEnvironment: EnvironmentDetails = CustomEnvironment(chatURL: "", socketURL: "", loggerURL: "", tokenURL: "")

    // MARK: - Init

    init(
        keychainService: any KeychainStorage,
        userDefaultsService: UserDefaultsService,
        session: (any URLSessionProtocol)? = nil,
        environment: EnvironmentDetails = ConnectionContextImpl.defaultEnvironment,
        brandId: Int = .min,
        deviceToken: String? = nil,
        authorizationCode: String = "",
        codeVerifier: String = "",
        contactId: String? = nil,
        channelConfig: ChannelConfigurationDTO = ConnectionContextImpl.defaultChannelConfig,
        channelId: String = "",
        destinationId: String = LowercaseUUID().uuidString,
        visitDetailsStore: CurrentVisitDetails? = nil
    ) {
        self.keychainService = keychainService
        self.userDefaultsService = userDefaultsService
        #if DEBUG
        self.session = session ?? URLSession.lenient()
        #else
        self.session = session ?? URLSession.default
        #endif
        self._deviceToken = SafeAccessContainer(deviceToken)
        self._authorizationCode = SafeAccessContainer(authorizationCode)
        self._codeVerifier = SafeAccessContainer(codeVerifier)
        self._connectionToken = SafeAccessContainer(nil)
        self._connectionTokenExpiresAt = SafeAccessContainer(nil)
        self._tokenDelegateListener = SafeAccessContainer(nil)
        self._contactId = SafeAccessContainer(contactId)
        self._channelConfig = SafeAccessContainer(channelConfig)
        self._brandId = SafeAccessContainer(brandId)
        self._channelId = SafeAccessContainer(channelId)
        self._destinationId = SafeAccessContainer(destinationId)
        self._environment = SafeAccessContainer(environment)
        self._persistedSetPositionInQueueEvent = SafeAccessContainer(nil)
        self._lastPageViewed = SafeAccessContainer(nil)
        self._chatState = SafeAccessContainer(.initial)
        self._visitDetailsStore = SafeAccessContainer(visitDetailsStore)
        self._sessionGeneration = SafeAccessContainer(0)

        purgeKeychainOnFreshInstall()
    }

    // MARK: - Methods

    /// Ends the current session: purges persisted identity and resets the in-memory session state.
    ///
    /// The two purges below only reach the keychain and `UserDefaults`. Every other property lives in
    /// a `SafeAccessContainer` that they do not touch, so without the resets that follow a session's
    /// state outlives the sign-out meant to end it. Two cases are actively wrong rather than merely
    /// untidy: ``visitDetails`` reads its in-memory mirror before `UserDefaults` and so keeps serving
    /// the visit its backing store just lost, and ``chatState`` is left at `.prepared` by the
    /// disconnect that precedes this call — a state from which ``ConnectionProvider/connect()`` is
    /// legal, against an identity that no longer exists.
    ///
    /// ``deviceToken`` and ``tokenDelegateListener`` are deliberately preserved. Both are
    /// integrator-supplied registrations scoped to the application rather than to the chat session;
    /// clearing them would silently break push delivery and implicit-flow token refresh until the
    /// integrator happened to register them again.
    ///
    /// ``sessionGeneration`` is bumped first, before either purge, so a `prepare(brandId:channelId:)` or
    /// `connect()` call from the session that just ended — suspended on an `await` when this ran — sees
    /// the mismatch and abandons its remaining work as soon as it resumes, instead of racing the purges
    /// (keychain and `UserDefaults` I/O, unlike the in-memory resets below) and resurrecting stale state.
    nonisolated func clear() {
        _sessionGeneration.mutate { content in
            content += 1
        }

        keychainService.purge()
        userDefaultsService.purge()

        _channelConfig.mutate { content in
            content = Self.defaultChannelConfig
        }
        _environment.mutate { content in
            content = Self.defaultEnvironment
        }
        _brandId.mutate { content in
            content = .min
        }
        _channelId.mutate { content in
            content = ""
        }
        _destinationId.mutate { content in
            content = LowercaseUUID().uuidString
        }
        _contactId.mutate { content in
            content = nil
        }
        _connectionToken.mutate { content in
            content = nil
        }
        _connectionTokenExpiresAt.mutate { content in
            content = nil
        }
        _authorizationCode.mutate { content in
            content = ""
        }
        _codeVerifier.mutate { content in
            content = ""
        }
        _persistedSetPositionInQueueEvent.mutate { content in
            content = nil
        }
        _lastPageViewed.mutate { content in
            content = nil
        }
        _visitDetailsStore.mutate { content in
            content = nil
        }
        _chatState.mutate { content in
            content = .initial
        }
    }
}

// MARK: - Private Methods

private extension ConnectionContextImpl {

    /// Clears keychain identity left behind by a previous installation after an app reinstall.
    ///
    /// iOS keeps keychain items across an app uninstall but wipes the app's `UserDefaults`. The SDK
    /// splits identity across both stores — `customer` and `transactionToken` live in the keychain,
    /// while `visitorId` and `visitDetails` live in `UserDefaults`. After a reinstall the surviving
    /// keychain identity would be paired with a freshly-generated `visitorId`, producing an
    /// inconsistent identity that the backend accepts at the socket handshake but never answers, so
    /// thread loading times out and the chat is unreachable.
    ///
    /// The ``UserDefaultKeys/installationMarker`` sentinel is wiped along with the rest of
    /// `UserDefaults` on uninstall, so its absence marks either a genuine fresh install or the first
    /// launch after an existing installation upgrades to a marker-aware SDK version. Only the reinstall
    /// case must be purged, and it is distinguished by its identity fingerprint: a reinstall leaves a
    /// keychain identity (``customer`` or ``transactionToken``) with no ``visitorId`` to pair it with,
    /// because `UserDefaults` was wiped. An upgrade still has its `visitorId`, so its stored identity is
    /// consistent and is preserved — purging it would needlessly discard identity and force OAuth
    /// re-authentication for the entire existing user base. Either way the marker is recorded so later
    /// launches short-circuit.
    func purgeKeychainOnFreshInstall() {
        guard userDefaultsService.get(Bool.self, for: .installationMarker) != true else {
            return
        }

        let hasKeychainIdentity = customer != nil || transactionToken != nil
        let hasOrphanedKeychainIdentity = hasKeychainIdentity && visitorId == nil
        if hasOrphanedKeychainIdentity {
            LogManager.trace("Orphaned keychain identity (present without a visitorId) -> purging identity that likely survived a previous uninstall")

            keychainService.purge()
        }

        userDefaultsService.set(true, for: .installationMarker)
    }
}

// MARK: - Helpers

private extension URLSession {

    // periphery:ignore - False positive, used in a non DEBUG configuration
    static var `default`: URLSession {
        let configuration = URLSessionConfiguration.default

        return URLSession(configuration: configuration)
    }
}
