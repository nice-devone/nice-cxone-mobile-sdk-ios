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

/// Entry point of the CXone Chat SDK and the canonical conformer of ``ChatProvider``.
///
/// Construct one `CXoneChat` instance at app start with ``init()`` and hold the reference for
/// the lifetime of your chat experience. Pass it through your app as the protocol type
/// ``ChatProvider`` to keep code testable. Use the provider properties (``connection``,
/// ``customer``, ``threads``, ``analytics``, ``customerCustomFields``, ``proactiveAction``) to
/// drive the SDK; subscribe to ``events()`` for state changes, thread updates, and errors.
///
/// `CXoneChat` is `@MainActor`-isolated — call sites from background contexts must hop to the
/// main actor (see the ``ChatProvider`` protocol docs and the
/// [Migration Guide](doc:migration-from-singleton) for details).
///
/// > Important: Earlier SDK versions exposed `CXoneChat.shared` and `CXoneChatDelegate`. Both
///   are removed. See [migration-from-singleton.md](doc:migration-from-singleton) for the
///   upgrade walkthrough.
@MainActor
public final class CXoneChat: ChatProvider {
    
    // MARK: - Public properties
    
    /// The handler for the logs occured in CXoneChat.
    public static var logWriter: LogWriter? {
        get { LogManager.instance }
        set { LogManager.instance = newValue }
    }
    
    /// Current chat state of the SDK
    ///
    /// The state defines if the SDK is prepared for API services (analytics), connected for chat features
    /// or if it needs to be prepared or connected for proper usage.
    public var state: ChatState {
        resolver.connectionContext.chatState
    }
    
    /// Chat mode defining available functionality.
    public var mode: ChatMode {
        resolver.connectionContext.chatMode
    }
    
    // MARK: - API providers
    
    /// The provider for connection related properties and methods.
    public let connection: ConnectionProvider
    /// The provider for customer related properties and methods.
    public let customer: CustomerProvider
    /// The provider for customer chat fields related properties and methods.
    public let customerCustomFields: CustomerCustomFieldsProvider
    /// The provider for thread related properties and methods.
    public let threads: ChatThreadListProvider
    /// The provider for report related properties and methods.
    public let analytics: AnalyticsProvider
    /// The provider for proactive action related properties and methods.
    public let proactiveAction: ProactiveActionProvider

    // MARK: - Private properties

    private let resolver: DependencyManager

    // MARK: - Internal properties
    
    /// Forwarding accessor used by the test target via `@testable import`.
    var socketService: SocketService {
        resolver.socketService
    }
    /// Forwarding accessor used by the test target via `@testable import`.
    var broadcaster: EventBroadcaster {
        resolver.broadcaster
    }

    // MARK: - Init

    /// Creates a new `CXoneChat` instance with default SDK-internal services
    /// (keychain-backed token storage, `UserDefaults`-backed visitor state, real WebSocket
    /// transport).
    ///
    /// Construct once at app start and hold the reference for the lifetime of the chat
    /// experience — see ``CXoneChat`` for the ownership and lifecycle rules.
    public convenience init() {
        self.init(
            socketService: SocketServiceImpl(
                connectionContext: ConnectionContextImpl(
                    keychainService: KeychainService(),
                    userDefaultsService: UserDefaultsServiceImpl()
                )
            )
        )
    }
    
    init(socketService: SocketService) {
        self.resolver = DependencyManager(socketService: socketService)
        self.connection = resolver.resolve()
        self.customer = resolver.resolve()
        self.customerCustomFields = resolver.resolve()
        self.threads = resolver.resolve()
        self.analytics = resolver.resolve()
        self.proactiveAction = resolver.resolve()
    }
}

// MARK: - Public methods

public extension CXoneChat {

    /// Returns a new ``AsyncStream`` of all SDK events.
    ///
    /// Each call produces an **independent** stream — multiple components in your app can
    /// each subscribe and all receive every event. There is no fan-in or de-duplication
    /// across subscribers; cancelling one task does not affect the others.
    ///
    /// ```swift
    /// let observation = Task { [chatProvider] in
    ///     for await event in chatProvider.events() {
    ///         switch event {
    ///         case .threadUpdated(let thread): /* handle */ break
    ///         case .error(let error): /* surface to user */ break
    ///         default: break
    ///         }
    ///     }
    /// }
    /// // Later, to stop observing:
    /// observation.cancel()
    /// ```
    ///
    /// ## Lifecycle
    /// - The stream **never finishes with an error.** SDK errors arrive as the
    ///   ``ChatEvent/error(_:)`` case — handle it as you would any business-level
    ///   error (surface to the user, log, retry, etc.).
    /// - Calling ``signOut()`` finishes every active stream cleanly — each
    ///   `for await` loop exits normally with no error.
    /// - To stop observing without signing out, cancel the wrapping `Task`.
    /// - Each stream buffers at most 64 events; if the consuming `Task` falls
    ///   behind, the **oldest** buffered events are silently dropped. Keep the
    ///   `for await` body lightweight or hand off heavy work via `Task { }`.
    func events() -> AsyncStream<ChatEvent> {
        resolver.broadcaster.makeStream()
    }

    /// Signs the customer out, disconnects from the CXone service, and clears persistent state.
    ///
    /// Calling this method:
    /// 1. Disconnects the WebSocket cleanly (does **not** emit ``ChatEvent/unexpectedDisconnect``).
    /// 2. Purges the SDK's keychain entries and UserDefaults state.
    /// 3. Finishes every active ``events()`` stream — observers see their `for await` loop exit normally.
    ///
    /// The instance remains alive and **reusable** after `signOut()`. You can call
    /// ``ConnectionProvider/prepare(environment:brandId:channelId:)`` and
    /// ``ConnectionProvider/connect()`` again to start a new session with fresh credentials.
    /// If you prefer a clean slate, discard this instance and construct a new ``CXoneChat``.
    func signOut() {
        LogManager.trace("Signing out of the current brand and channel configuration")

        (connection as? ConnectionService)?.signOut()
    }
}
