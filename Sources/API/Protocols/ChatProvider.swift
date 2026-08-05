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

/// The interface for interacting with chat features of the CXone platform.
@MainActor
public protocol ChatProvider: AnyObject, Sendable {
    /// The handler for the logs occured in CXone chat.
    static var logWriter: LogWriter? { get set }

    /// Current chat state of the SDK
    ///
    /// The state defines whether it is necessary to set up the SDK, connect to the CXone services or start communication with an agent.
    var state: ChatState { get }
    
    /// Chat mode based on the channel configuration
    var mode: ChatMode { get }
    
    /// The provider for connection related properties and methods.
    var connection: ConnectionProvider { get }
    
    /// The provider for customer related properties and methods.
    var customer: CustomerProvider { get }
    
    /// The provider for customer chat fields related properties and methods.
    var customerCustomFields: CustomerCustomFieldsProvider { get }
    
    /// The provider for thread related properties and methods.
    var threads: ChatThreadListProvider { get }
    
    /// The provider for report related properties and methods.
    var analytics: AnalyticsProvider { get }
    
    /// The provider for handling user responses to proactive actions such as inactivity popups, custom automation popups,
    /// and future automated engagement features.
    ///
    /// Use this provider to send user interaction results (e.g., "Continue", "Close", etc.) for proactive UI elements back to the backend.
    var proactiveAction: ProactiveActionProvider { get }
    
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
    func events() -> AsyncStream<ChatEvent>

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
    func signOut()
}
