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

/// Class for interacting with the WebSocket.
///
/// - Note: `@unchecked Sendable` is safe here because all mutable state is
///   serialised by `SafeAccessContainer` (OSAllocatedUnfairLock-backed):
///   `_socket`, `eventTransfer`, `_pongReceived`, `_consecutivePongs`, `_pulseTimer`,
///   `reconnectTask`, `_retryAttempt`, `_reconnectBackoff`, `_isHandlingDisconnect`, `_delegate`,
///   `_listenerTasks`.
///   The three immutable `let` properties (`broadcaster`, `connectionContext`,
///   `eventBroadcast`) are themselves `Sendable`.
final class SocketServiceImpl: NSObject, SocketService, EventReceiver, @unchecked Sendable {

    // MARK: - Properties

    let broadcaster = EventBroadcaster()
    let connectionContext: ConnectionContext
    let eventBroadcast = EventBroadcast()

    private let encoder = JSONEncoder()

    var delegate: (any SocketDelegate)? {
        get { _delegate.content.object as? (any SocketDelegate) }
        set {
            _delegate.mutate { delegate in
                delegate = WeakContainer(newValue.map { value in value as AnyObject })
            }
        }
    }
    /// Whether the socket is currently connected.
    var isConnected: Bool {
        connectionContext.chatState.isChatAvailable && _socket.content != nil
    }
    var urlSession: URLSessionProtocol {
        connectionContext.session
    }
    
    /// The WebSocket for sending and receiving messages.
    private let _socket = SafeAccessContainer<WebSocketProtocol?>(nil)
    private let eventTransfer = SafeAccessContainer<Task<Void, Never>?>(nil)
    /// Whether a pong was received for the heartbeat message.
    private let _pongReceived = SafeAccessContainer<Bool>(false)
    /// Number of consecutive heartbeat pongs received on the current connection.
    ///
    /// Used to decide when a connection is stable enough to refill the reconnect budget. Reset to
    /// zero on every teardown (`resetProperties()`), so a connection that flaps before answering
    /// `stablePongThreshold` pongs never refills the budget and eventually gives up.
    private let _consecutivePongs = SafeAccessContainer<Int>(0)
    /// The timer for when pulse messages should be sent.
    private let _pulseTimer = SafeAccessContainer<Task<(), Never>?>(nil)
    /// Guards against a single drop being handled twice.
    ///
    /// A dropped socket is typically reported by two independent sources at once — the failing
    /// `receive` stream (`addEventTransfer`) and the heartbeat pulse timeout (`verifyPulse`). Without
    /// this guard both would call `handleWebSocketDisconnect` and each would consume a retry attempt
    /// for the same drop, halving the effective budget. Set by the first reporter; cleared at the
    /// start of every `connect()` so each fresh connection's disconnects are handled again.
    private let _isHandlingDisconnect = SafeAccessContainer<Bool>(false)
    /// The in-flight automatic reconnect.
    ///
    /// Tracked separately from `eventTransfer`/`pulseTimer` on purpose: `resetProperties()`
    /// cancels those two, but must NOT cancel the task that performs the reconnect backoff,
    /// otherwise the backoff `Task.sleep` would return immediately (cooperative cancellation)
    /// and the whole exponential backoff would collapse. Deliberately NOT cancelled by
    /// `resetProperties()`; it is cancelled by `disconnect()` and by `scheduleReconnect()` when a
    /// newer reconnect supersedes it (so attempts never stack).
    private let reconnectTask = SafeAccessContainer<Task<Void, Never>?>(nil)
    // `nil` means the reconnect mechanism is disabled / not armed. This is an expected state, not an
    // error: before the first `connect()`, after an intentional `disconnect()`, and after the retry
    // budget is exhausted. A non-nil value is the current 1-based retry attempt counter.
    private let _retryAttempt = SafeAccessContainer<Int?>(nil)
    /// Sleep used to space out reconnect attempts (exponential backoff).
    ///
    /// Injectable so tests can make the backoff deterministic and instantaneous; defaults to a
    /// real-time sleep. Propagates `CancellationError` so a `disconnect()` during backoff stops
    /// the pending reconnect instead of silently completing.
    private let _reconnectBackoff = SafeAccessContainer<@Sendable (TimeInterval) async throws -> Void> { seconds in
        try await Task.sleep(seconds: seconds)
    }
    var reconnectBackoff: @Sendable (TimeInterval) async throws -> Void {
        get { _reconnectBackoff.content }
        set { _reconnectBackoff.mutate { closure in closure = newValue } }
    }
    private let _delegate = SafeAccessContainer<WeakContainer<AnyObject>>(WeakContainer())
    
    /// The maximum number of retry attempts allowed for reconnecting.
    ///
    /// Used to prevent infinite retry loops and to define a reasonable upper limit for backoff strategy.
    private static let retryMaxAttempts: Int = 20
    /// Number of consecutive heartbeat pongs that mark a connection as durably stable, at which
    /// point the reconnect budget is refilled.
    ///
    /// Requiring several pongs (rather than a single one) prevents a briefly-healthy but flapping
    /// connection from resetting the budget every cycle and reconnecting forever.
    private static let stablePongThreshold: Int = 3

    // MARK: - EventReceiver

    private let _listenerTasks = SafeAccessContainer<[Task<Void, Never>]>([])
    var listenerTasks: [Task<Void, Never>] {
        get { _listenerTasks.content }
        set {
            _listenerTasks.mutate { content in
                content = newValue
            }
        }
    }

    // MARK: - Init
    
    init(connectionContext: ConnectionContext) {
        self.connectionContext = connectionContext
    }
    
    // MARK: - Methods
    
    /// - Throws: ``CXoneChatError/notConnected`` if an attempt was made to use a method without connecting first.
    ///     Make sure you call the `connect` method first.
    func checkForConnection() throws {
        if !isConnected {
            disconnect(unexpectedly: false)

            throw CXoneChatError.notConnected
        }
    }
    
    /// Opens a new WebSocket connection using the specified URL.
    ///
    /// - Parameter socketURL: The URL for the location of the WebSocket.
    func connect(socketURL: URL) async throws {
        // Redact the transaction token before logging: the URL embeds it as a query item and it is
        // a credential that must not be written to logs (even at trace level).
        LogManager.trace("Opening new websocket connection with url: \(socketURL.redactingTransactionToken)")

        // Starting a fresh connection lifecycle: allow the next drop to be handled. Cleared here
        // (rather than on teardown) so a failed reconnect's own catch can still schedule the next
        // attempt — by the time it runs, this connect() has already reset the guard.
        _isHandlingDisconnect.mutate { flag in
            flag = false
        }

        // Create the socket first and capture it in a local constant so we can
        // call resume() on the same instance we just stored. Reading _socket.content
        // in a second lock acquisition after the mutate would introduce a TOCTOU:
        // a concurrent disconnect() could nil out _socket between the two operations.
        let socket = urlSession.webSocketProtocol(with: socketURL)

        _socket.mutate { content in
            content = socket
        }

        do {
            try await socket.resume()
        } catch {
            _socket.mutate { socket in
                socket = nil
            }
            throw error
        }

        // Enable the reconnect mechanism on the very first connect only. Do NOT reset the
        // counter on reconnects here: a socket that completes the handshake but immediately
        // drops must keep climbing toward `retryMaxAttempts`, otherwise a flapping server —
        // one that accepts the connection and drops it right away — would loop forever and
        // never surface an error. The budget is refilled only once the connection proves
        // durably stable (`stablePongThreshold` consecutive pongs), see `handleMessage`.
        //
        // Skip arming when the current task is cancelled: an intentional disconnect() that lands
        // while a reconnect is suspended in `socket.resume()` nils `retryAttempt` and cancels the
        // task. `resume()` does not honor cooperative cancellation, so it completes anyway — but
        // re-arming here would defeat the post-connect teardown guard in `performReconnect` and
        // leave a zombie socket. Reconnects don't re-arm because `retryAttempt` is already non-nil.
        let didArmReconnect = _retryAttempt.mutate { ref -> Bool in
            if ref == nil, !Task.isCancelled {
                ref = 1

                return true
            }

            return false
        }

        if didArmReconnect {
            LogManager.trace("WebSocket successfully connected -> reconnect mechanism enabled")
        }

        addListeners()

        // Create a pulse timer to regularly check connection status
        _pulseTimer.mutate { content in
            content = startPulseTimer()
        }
    }
    
    /// Closes the current WebSocket session.
    ///
    /// - Parameter unexpectedly: Indicates whether the disconnection was unexpected.
    func disconnect(unexpectedly: Bool) {
        delegate?.didCloseConnection(unexpectedly: unexpectedly)

        // Order matters: cancel the reconnect task BEFORE nilling `retryAttempt`. A reconnect
        // suspended inside connect() re-arms `retryAttempt` only when `ref == nil && !Task.isCancelled`
        // (see connect()). Nilling first would open a window where an in-flight reconnect sees the
        // flag cleared but the task not yet cancelled, re-arms `retryAttempt` to 1, and defeats the
        // post-connect teardown guard in performReconnect() — leaving a zombie socket + pulse timer
        // that reconnects ~15s later despite the intentional disconnect. Cancelling first makes the
        // `!Task.isCancelled` guard reliable, so the re-arm never fires during an intentional disconnect.
        //
        // resetProperties() deliberately does not touch reconnectTask (it is called from within the
        // reconnect task itself), so an intentional disconnect must stop a scheduled reconnect here.
        reconnectTask.mutate { task in
            task?.cancel()
            task = nil
        }
        // Invalidate the retryAttempt state to reinitialize the exp. backoff mechanism logic for reconnect
        _retryAttempt.mutate { content in
            content = nil
        }
        // Reset remaining properties of the service
        resetProperties()
    }
    
    /// Sends a message through the WebSocket.
    ///
    /// - Parameters:
    ///   - data: The serialised payload to send.
    ///   - shouldCheck: Whether to refresh an expiring credential (access token or implicit
    ///     connection token) before sending.
    ///
    /// - Note: The underlying WebSocket write is **fire-and-forget**. Returning
    ///   normally does *not* guarantee delivery; it only means the message was
    ///   accepted for transmission. Use `EventBroadcast.waitFor(_:…:socketService:)`
    ///   when delivery confirmation (a server-side response) is required.
    ///
    /// - Throws: ``CXoneChatError/invalidData`` when `data` cannot be decoded as
    ///   a valid UTF-8 string.
    /// - Throws: ``CXoneChatError/invalidAccessToken`` when the credential needs a refresh,
    ///   `shouldCheck` is `true`, and no delegate is available to refresh it.
    /// - Throws: Any error propagated by the token-refresh delegate when the
    ///   credential needs a refresh and `shouldCheck` is `true`.
    func send(data: Data, shouldCheck: Bool = true) async throws {
        guard let message = data.utf8string else {
            throw CXoneChatError.invalidData
        }
        
        #if DEBUG
        // Redact credential-bearing keys BEFORE any formatting/logging — outbound event payloads
        // (e.g. `SendMessageEventDataDTO`) embed the connection/transaction token in a `"token"`
        // field. Logging the raw payload — even under `#if DEBUG` — leaks the credential into
        // device/console logs where it may end up in support bundles or crash reports.
        let redacted = message.redactingJSONCredentials
        LogManager.trace("Sending a message:\n\(redacted.formattedJSON ?? redacted)")
        #endif
        
        // Ensure the credential is fresh before ANY event reaches the backend — this is the single choke
        // point every outbound WS event passes through. The refresh policy lives on `ConnectionContext`
        // (`needsProactiveTokenRefresh`) so the socket layer doesn't own auth rules. Message-send paths that
        // embed the JWT refresh it before serialization in `ChatThreadService` and pass `shouldCheck: false`,
        // so a single refresh runs per event (matching the Android per-event guard).
        if shouldCheck, connectionContext.needsProactiveTokenRefresh {
            // Fail fast rather than silently skipping the refresh — sending with an expiring
            // credential leads to backend rejections that are harder to recover from.
            guard let delegate else {
                LogManager.warning("The credential is expiring but no socket delegate is available to refresh it")

                throw CXoneChatError.invalidAccessToken
            }

            LogManager.trace("The credential is expiring -> refreshing before send")

            try await delegate.refreshToken()

            LogManager.trace("The credential has been refreshed, continuing with the message send")
        }

        _socket.content?.send(.string(message))
    }

    func forward(data: Data) {
        if let rawString = data.utf8string {
            LogManager.trace("Handling event:\n\(rawString.formattedJSON ?? rawString)")
        } else {
            LogManager.trace("Handling event: invalid data (not UTF-8)")
        }

        if let event = data.toReceivedEvent() {
            eventBroadcast.send(event)
        }
    }
}

private extension SocketServiceImpl {
    
    // Adjusted values for debugging purposes
    #if DEBUG
    static let pingDelay = 100.0
    static let pingResponseTimeout = 100.0
    #else
    static let pingDelay = 10.0
    static let pingResponseTimeout = 5.0
    #endif

    func startPulseTimer() -> Task<(), Never> {
        LogManager.trace("Starting a pulse timer to verify the connection")
        
        return Task { [weak self] in
            while !Task.isCancelled {
                // Ignore cancellation of the sleep; the `Task.isCancelled` check below
                // governs loop exit.
                try? await Task.sleep(seconds: Self.pingDelay)

                if Task.isCancelled {
                    break
                }
                
                self?.sendPulse()

                if Task.isCancelled {
                    break
                }
                
                do {
                    try await self?.verifyPulse(delay: Self.pingResponseTimeout)
                } catch {
                    await self?.handleWebSocketDisconnect(error: WebSocketError.protocolError(error))
                    // Stop the loop if the pulse verification fails
                    break
                }
            }
        }
    }

    /// Sends a heartbeat message through the WebSocket and verifies the response.
    func sendPulse() {
        do {
            guard let utf8string = try encoder.encode(HeartbeatDTO()).utf8string else {
                throw CXoneChatError.missingParameter("utf8string")
            }

            _pongReceived.mutate { content in
                content = false
            }

            _socket.content?.send(.string(utf8string))
        } catch {
            error.logError()
        }
    }

    /// Verifies that a pong was received. If it wasn't received, the WebSocket connection is closed.
    ///
    /// - Throws: ``CXoneChatError/notConnected`` if the pulse was not received
    func verifyPulse(delay: Double) async throws {
        // Ignore cancellation of the sleep; the guard below handles a cancelled pulse timer
        // without misreporting it as a missed pong.
        try? await Task.sleep(seconds: delay)

        if Task.isCancelled || _pulseTimer.content == nil || _pulseTimer.content?.isCancelled == true {
            return
        }

        if _pongReceived.content == false {
            LogManager.trace("Pong was not received.")

            throw CXoneChatError.notConnected
        }
    }

    /// Starts listening for any message that is received from the WebSocket and handles it.
    func addListeners() {
        // add listeners to socket
        addEventTransfer()

        // add listeners to events
        addListener { [weak self] event in
            self?.downloadEventContentFromS3(event)
        }
        addListener { [weak self] event in
            self?.onOperationError(event)
        }
    }

    func addEventTransfer() {
        guard let socket = _socket.content else {
            LogManager.error("Socket is nil, cannot add event transfer")
            return
        }

        let stream = socket.receive
        
        eventTransfer.mutate { content in
            content = Task { [weak self] in
                do {
                    for try await message in stream {
                        self?.handleMessage(message)
                    }

                    await self?.handleWebSocketDisconnect(error: nil)
                } catch is CancellationError {
                    // Task was cancelled intentionally (e.g. disconnect() called) — no further action.
                } catch {
                    await self?.handleWebSocketDisconnect(error: error)
                }
            }
        }
    }

    func handleMessage(_ message: URLSessionWebSocketTask.Message) {
        switch message {
        case .data:
            LogManager.trace("Did receive data")
        case .string(let text):
            if text == #""pong""# {
                _pongReceived.mutate { content in
                    content = true
                }

                // Refill the reconnect budget only once the connection has proven durably stable —
                // after `stablePongThreshold` consecutive heartbeat pongs, not a single one. A
                // connection that repeatedly connects, answers one pong, then drops never
                // accumulates enough consecutive pongs (the counter is reset on every teardown), so
                // it still exhausts `retryMaxAttempts` and gives up instead of reconnecting forever.
                let consecutivePongs = _consecutivePongs.mutate { count -> Int in
                    count += 1
                    return count
                }
                if consecutivePongs >= Self.stablePongThreshold {
                    // Leave `nil` (reconnect disabled) untouched.
                    _retryAttempt.mutate { ref in
                        if ref != nil {
                            ref = 1
                        }
                    }
                }
            } else if let data = text.data(using: .utf8) {
                forward(data: data)
            }
        @unknown default:
            LogManager.warning("Listener did received unknown response case - \(message)")
        }
    }
    
    func onOperationError(_ error: OperationError) {
        switch error.errorCode {
        case .inconsistentData, .unknown:
            broadcaster.send(.error(error))
        case .recoveringThreadFailed, .recoveringLivechatFailed, .sendingTranscriptFailed:
            // these are handled elsewhere
            break
        }
    }
    
    func resetProperties() {
        LogManager.trace("Reseting SocketService's properties, ie. cancelling all cancellables, resetting socket, eventTransfer and pulseTimer")

        _listenerTasks.mutate { tasks in
            tasks.forEach { task in
                task.cancel()
            }
            tasks.removeAll()
        }

        // Finish all active EventBroadcast streams so that any pending waitFor
        // calls (whose tasks are NOT in listenerTasks) unblock immediately with
        // CXoneChatError.invalidData instead of waiting for the response timeout.
        eventBroadcast.invalidate()
        _socket.mutate { socket in
            socket?.cancel(with: .goingAway, reason: nil)
            socket = nil
        }

        eventTransfer.mutate { transfer in
            transfer?.cancel()
            transfer = nil
        }

        _pulseTimer.mutate { timer in
            timer?.cancel()
            timer = nil
        }

        // The connection is gone, so the consecutive-pong streak is broken. Reset it so the next
        // connection must prove its own stability before the reconnect budget is refilled.
        _consecutivePongs.mutate { count in
            count = 0
        }
    }

    func handleWebSocketDisconnect(error: (any Error)?) async {
        LogManager.trace("WebSocket closed: \(error?.localizedDescription ?? "normally")")

        // A single drop is usually reported twice at once — by the failing `receive` stream and by
        // the heartbeat pulse timeout. Only the first report may proceed; a duplicate would consume
        // a second retry attempt for the same drop. Check-and-set atomically so the two racing
        // reporters can't both pass. The guard is reset at the start of every `connect()`.
        let alreadyHandling = _isHandlingDisconnect.mutate { flag -> Bool in
            if flag {
                return true
            }

            flag = true

            return false
        }
        guard !alreadyHandling else {
            LogManager.trace("Disconnect already being handled -> ignoring duplicate report")

            return
        }

        // Try to automatically reconnect
        let retryAttempt = _retryAttempt.mutate { ref -> Int? in
            guard let current = ref, current <= Self.retryMaxAttempts else {
                // Budget exhausted (or reconnect already disabled): clear the state so a later
                // manual connect() can re-arm the reconnect mechanism. Leaving a stale value
                // greater than `retryMaxAttempts` would stop connect() from arming (it only arms
                // when nil) and make the next disconnect give up immediately.
                ref = nil

                return nil
            }

            ref = current + 1

            return current
        }
        if let retryAttempt {
            LogManager.trace("`retryAttempt` is set to valid value -> schedule the reconnect")

            scheduleReconnect(attempt: retryAttempt)
        } else {
            // The reconnect budget is spent. Surface the failure (if any) and then tear the
            // connection down to a recoverable state regardless of whether an error was reported.
            //
            // Previously the error path only logged + surfaced the error and skipped teardown,
            // leaving `chatState` at `.connecting` (set by `performReconnect`). `connect()` treats
            // `.connecting` as a no-op, so the SDK could never auto-recover once the network
            // returned — a permanent dead-end until an explicit `disconnect()`. Always going through
            // `disconnect()` settles the state back to `.prepared` (via `didCloseConnection`), so a
            // later `connect()` can start a fresh connection.
            if let error {
                error.logError()

                delegate?.didReceive(error: error)
            }

            // Tear down with `unexpectedly: false`. The failure, if any, is already surfaced above
            // via `didReceive(error:)` (-> `.error`). Passing `unexpectedly: true` here would make
            // `didCloseConnection` emit a second `.unexpectedDisconnect` for the same give-up,
            // double-notifying consumers — and driving an auto-reconnect-on-disconnect consumer into
            // a loop against a genuinely-failing endpoint. `chatState` is settled back to `.prepared`
            // regardless of the flag, so auto-recovery is preserved either way.
            disconnect(unexpectedly: false)
        }
    }
    
    /// Schedules an automatic reconnect attempt on a dedicated, separately-tracked task.
    ///
    /// The reconnect MUST run on its own task — not the `eventTransfer`/`pulseTimer` task that
    /// triggered the disconnect — because the first thing it does is call `resetProperties()`,
    /// which cancels those tasks. If the backoff `Task.sleep` ran on a task that had just been
    /// cancelled, cooperative cancellation would make the sleep return immediately, collapsing
    /// the exponential backoff and burning through every retry in a few milliseconds (all 20
    /// attempts fired in ~3s in the field). `reconnectTask` is not cancelled by
    /// `resetProperties()`, so the delay is honoured; it is cancelled by `disconnect()` and, just
    /// below, by this method itself when a newer reconnect supersedes the previous one.
    func scheduleReconnect(attempt: Int) {
        LogManager.trace("Scheduling reconnect of the websocket")

        reconnectTask.mutate { task in
            // Never let reconnect attempts stack.
            task?.cancel()

            task = Task { [weak self] in
                await self?.performReconnect(attempt: attempt)
            }
        }
    }

    /// Performs a single automatic reconnect attempt on the dedicated `reconnectTask`: tears down
    /// the dead connection, waits out the exponential backoff, then re-establishes the WebSocket.
    func performReconnect(attempt: Int) async {
        // An intentional disconnect() nils `retryAttempt` and cancels the reconnect task. Because
        // `handleWebSocketDisconnect` and `disconnect()` run without mutual exclusion (cooperative
        // cancellation), a reconnect can be scheduled just after `disconnect()` already ran — the
        // newly created task would not observe the cancellation. Bail out if the retry state was
        // cleared, so an intentional disconnect is never followed by an automatic reconnect.
        guard _retryAttempt.content != nil else {
            LogManager.trace("Reconnect skipped — chat was intentionally disconnected")
            return
        }

        // Tear down the dead connection's socket, listeners and pulse timer. This does
        // NOT cancel the current (reconnect) task, so the backoff below is honoured.
        resetProperties()

        LogManager.info("Attempting to reconnect (\(attempt)/\(Self.retryMaxAttempts))")

        // `attempt` is the human-facing 1-based counter (1/20, 2/20, …). The backoff helper is
        // 0-based (like `Task.retrying`), so subtract 1 to keep one convention SDK-wide — the first
        // reconnect then waits `pow(1.3, 0)` rather than `pow(1.3, 1)`.
        let delay = TimeInterval.calculateExponentialBackoffDelay(attempt: attempt - 1)

        LogManager.info("Reconnect delayed by \(delay) seconds")

        do {
            try await reconnectBackoff(delay)
        } catch is CancellationError {
            // Backoff was cancelled (e.g. an explicit disconnect() during the wait) —
            // abandon this reconnect instead of connecting anyway.
            LogManager.trace("Reconnect cancelled during backoff")
            return
        } catch {
            // Any other backoff failure is unexpected; don't connect on a broken delay.
            LogManager.error("Reconnect backoff failed: \(error.localizedDescription)")
            return
        }

        guard !Task.isCancelled else {
            LogManager.trace("Reconnect cancelled during backoff")
            return
        }

        // Restart the connection flow
        do {
            // Transition to `.connecting` BEFORE rebuilding the URL, because `recreateSocketURL()`
            // may invoke the integrator's OAuth refresh delegate (via `ConnectionService.buildSocketURL()`).
            // The integrator observes chat state to gate UI (e.g. disable send while reconnecting), and
            // seeing a token-refresh callback while state is still `.connected` from before the drop
            // is surprising. Setting `.connecting` first preserves the pre-DE-121607 semantic where
            // token-refresh listeners always fire during a `.connecting` phase.
            if connectionContext.chatState != .connecting {
                LogManager.trace("Setting chat state to `.connecting`")

                connectionContext.chatState = .connecting
                broadcaster.send(.chatUpdated(state: connectionContext.chatState, mode: connectionContext.chatMode))
            }

            // Rebuild the socket URL with a freshly-minted transaction token instead of replaying the
            // original one. The socket URL embeds the transaction token, which expires after a few
            // minutes; replaying the stale URL makes the gateway reject the handshake (`-1011`) so
            // every reconnect fails until the retry budget is exhausted. Delegating the rebuild
            // re-mints the token (see `ConnectionService.buildSocketURL()`).
            //
            // From the second attempt onwards force a fresh token: the first attempt reuses the cached
            // one (the common case is a transient network drop with a still-valid token, so re-minting
            // every time is wasteful), but once an attempt has already failed the token itself is a
            // suspect — the server may have invalidated it while it still looks valid by the device
            // clock (key rotation, session cleanup, deploy, revocation, clock skew). Forcing then lets
            // the retry chain self-heal instead of replaying the rejected token across the whole budget.
            guard let socketURL = try await delegate?.recreateSocketURL(forceRefresh: attempt > 1) else {
                LogManager.error("Cannot reconnect — no delegate available to rebuild the socket URL")
                disconnect(unexpectedly: true)
                return
            }

            // A disconnect() may have landed while the token/URL was being rebuilt (an await point).
            guard !Task.isCancelled else {
                LogManager.trace("Reconnect cancelled during URL rebuild")

                if _retryAttempt.content == nil {
                    resetProperties()
                }
                return
            }

            // Establish the WebSocket connection
            try await connect(socketURL: socketURL)

            // A disconnect() may have landed while connect() was in flight — socket.resume()
            // does not honor cooperative cancellation, so the socket can reopen after the
            // user intentionally disconnected.
            guard !Task.isCancelled else {
                // Cancellation here has two possible sources: an intentional disconnect()
                // (which nils `retryAttempt` before cancelling) or this reconnect being
                // superseded by a newer one (which increments `retryAttempt`, leaving it
                // non-nil, before cancelling). Only in the disconnect case do we tear down
                // the socket connect() just re-established; a superseding reconnect owns the
                // state and will reset it itself.
                if _retryAttempt.content == nil {
                    LogManager.trace("Reconnect cancelled by disconnect -> tearing down the re-established socket")

                    resetProperties()
                }
                return
            }

            // Notify about the successful reconnection (retrigger the automated connection flow)
            try await delegate?.reconnect()
        } catch {
            error.logError()

            // If this reconnect task was already superseded — the re-established connection's
            // stream failed and `handleWebSocketDisconnect` already scheduled the next attempt,
            // cancelling us — don't schedule a second reconnect. Doing so would consume the
            // retry budget twice per flap and give up after roughly half of `retryMaxAttempts`.
            guard !Task.isCancelled else {
                return
            }

            // Re-open the duplicate-disconnect guard before re-handling. It is otherwise cleared only
            // by `connect()`, but a throw from `recreateSocketURL()` (e.g. token minting failing) lands
            // here *before* `connect()` runs, leaving the guard set. Without this reset, the recursive
            // `handleWebSocketDisconnect` below would treat the failure as a duplicate and silently
            // abandon the retry chain. Safe against the initial-drop dedupe race: this only runs after
            // the backoff, by which point both concurrent disconnect reporters have already been seen.
            _isHandlingDisconnect.mutate { flag in
                flag = false
            }

            // Preserve `CXoneChatError` (e.g. `invalidAccessToken` from recreateSocketURL()'s
            // token-mint / OAuth-refresh preflight) so consumers can detect token-related failures;
            // only wrap genuine non-SDK failures as a protocol error.
            let disconnectError: any Error
            if let sdkError = error as? CXoneChatError {
                disconnectError = sdkError
            } else {
                disconnectError = WebSocketError.protocolError(error)
            }

            await handleWebSocketDisconnect(error: disconnectError)
        }
    }

    /// - Throws: ``URLError.badServerResponse`` if the URL Loading system received bad data from the server.
    /// - Throws: ``NSError`` object that indicates why the request failed
    /// - Throws: ``CXoneChatError/serverError`` if the server experienced an internal error and was unable to perform the action.
    func downloadEventContentFromS3(_ object: EventInS3DTO) {
        LogManager.trace("Downloads the content of the `\(object.originEventType)` event stored in S3")

        Task { [weak self] in
            guard let self else {
                return
            }

            let request = URLRequest(url: object.url, method: .get, contentType: "application/json")

            do {
                let (data, response) = try await self.connectionContext.session.fetch(for: request)
                
                guard let response = response as? HTTPURLResponse, (200 ... 299) ~= response.statusCode else {
                    LogManager.error("Error downloading s3 event")
                    return
                }
                
                self.forward(data: data)
            } catch {
                error.logError()

                delegate?.didReceive(error: error)
            }
        }
    }
}
