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

import Combine
import Foundation

/// Async/await bridge for the SDK's socket event request-response pattern.
///
/// The SDK communicates with the server over a WebSocket. Every operation follows the same
/// pattern: send an outgoing event, then wait for the corresponding inbound event whose
/// `eventId` matches the one that was sent. These helpers wrap that pattern into a single
/// `async throws` call so callers can write linear code instead of managing Combine
/// subscriptions manually.
///
/// Internally, the implementation:
/// 1. Establishes Combine subscriptions on the shared event publisher.
/// 2. Fires the outgoing socket send **after** subscriptions are ready (avoiding a race
///    condition where a fast response would arrive before the subscriber was registered).
/// 3. Bridges the first matching inbound event back to the `async` caller via a
///    `CheckedContinuation`.
/// 4. Applies a timeout (``EventsService/responseTimeout``) so the caller always gets a
///    definitive result rather than suspending forever if the server never responds.
extension AnyPublisher<any ReceivedEvent, Never> {

    /// Sends `event` over the socket and waits for the first inbound event whose Swift type
    /// matches `dataType` and whose `eventId` echoes the outgoing event's id.
    ///
    /// Use this overload when the expected response type unambiguously identifies the event
    /// (i.e. only one `EventType` maps to `dataType`).
    ///
    /// - Parameters:
    ///   - dataType: The concrete ``ReceivedEvent`` type to decode the response into.
    ///   - event: The outgoing ``EventDTO`` to serialize and send.
    ///   - checkTokenExpiration: When `true` the socket service validates the access token
    ///     before sending. Defaults to `true`.
    ///   - socketService: Used to send the serialized event over the WebSocket.
    ///   - eventsService: Used to serialize `event` into `Data`.
    ///   - cancellables: The subscriptions created here are stored here so they remain alive
    ///     until the caller releases them.
    ///   - file: Propagated to log messages for call-site attribution.
    ///   - line: Propagated to log messages for call-site attribution.
    /// - Returns: The first inbound event that matches both type and `eventId`.
    /// - Throws: ``CXoneChatError/eventTimeout`` if no matching response arrives within
    ///   ``EventsService/responseTimeout`` seconds.
    /// - Throws: ``CXoneChatError/invalidData`` if a matching event was received but could
    ///   not be stored (should not happen in practice).
    /// - Throws: Any ``OperationError`` returned by the server for this event id.
    /// - Throws: Any error thrown by ``SocketService/send(data:shouldCheck:)``.
    @discardableResult
    func sink<Value: ReceivedEvent>(
        dataType: Value.Type,
        origin event: EventDTO,
        checkTokenExpiration: Bool = true,
        socketService: SocketService,
        eventsService: EventsService,
        cancellables: inout [AnyCancellable],
        file: StaticString = #file,
        line: UInt = #line
    ) async throws -> Value {
        try await self.sink(
            publisher: self.with(type: dataType),
            origin: event,
            checkTokenExpiration: checkTokenExpiration,
            socketService: socketService,
            eventsService: eventsService,
            cancellables: &cancellables,
            file: file,
            line: line
        )
    }

    /// Sends `event` over the socket and waits for the first inbound event matching the
    /// given `type` tag, decoded as `dataType`.
    ///
    /// Use this overload when you need to disambiguate by ``EventType`` because the same
    /// Swift type could represent multiple event kinds.
    ///
    /// - Parameters:
    ///   - type: The ``EventType`` that identifies the expected server response.
    ///   - dataType: The concrete ``ReceivedEvent`` type to decode the response into.
    ///   - event: The outgoing ``EventDTO`` to serialize and send.
    ///   - checkTokenExpiration: When `true` the socket service validates the access token
    ///     before sending. Defaults to `true`.
    ///   - socketService: Used to send the serialized event over the WebSocket.
    ///   - eventsService: Used to serialize `event` into `Data`.
    ///   - cancellables: The subscriptions created here are stored here so they remain alive
    ///     until the caller releases them.
    ///   - file: Propagated to log messages for call-site attribution.
    ///   - line: Propagated to log messages for call-site attribution.
    /// - Returns: The first inbound event that matches both `type`, `dataType`, and `eventId`.
    /// - Throws: ``CXoneChatError/eventTimeout`` if no matching response arrives within
    ///   ``EventsService/responseTimeout`` seconds.
    /// - Throws: ``CXoneChatError/invalidData`` if a matching event was received but could
    ///   not be stored (should not happen in practice).
    /// - Throws: Any ``OperationError`` returned by the server for this event id.
    /// - Throws: Any error thrown by ``SocketService/send(data:shouldCheck:)``.
    @discardableResult
    func sink<Value: ReceivedEvent>( // swiftlint:disable:this function_parameter_count
        type: EventType,
        as dataType: Value.Type,
        origin event: EventDTO,
        checkTokenExpiration: Bool = true,
        socketService: SocketService,
        eventsService: EventsService,
        cancellables: inout [AnyCancellable],
        file: StaticString = #file,
        line: UInt = #line
    ) async throws -> Value {
        try await self.sink(
            publisher: self.with(type: type, as: dataType),
            origin: event,
            checkTokenExpiration: checkTokenExpiration,
            socketService: socketService,
            eventsService: eventsService,
            cancellables: &cancellables,
            file: file,
            line: line
        )
    }
}

// MARK: - Helpers

private extension AnyPublisher<any ReceivedEvent, Never> {

    /// Core implementation of the request-response bridge.
    ///
    /// All public `sink` overloads funnel into this method after resolving the filtered
    /// `publisher` for the expected response type.
    ///
    /// ## Execution flow
    ///
    /// ```
    /// 1. Serialize the outgoing event (may throw — done before entering the continuation).
    /// 2. Enter a CheckedContinuation so the async caller suspends.
    /// 3. Subscribe to the response publisher (filtered by type + eventId).
    /// 4. Subscribe to OperationError events (server-side errors keyed by eventId).
    /// 5. Fire socketService.send() inside an unstructured Task — AFTER both subscriptions
    ///    are stored — so no response can arrive before we are ready to receive it.
    /// 6. One of three things resumes the continuation:
    ///      a. receiveValue  — matching response received → success path.
    ///      b. OperationError subscriber — server returned an error → throw OperationError.
    ///      c. .timeout completion — no response within responseTimeout → throw eventTimeout.
    ///    ResumeState.claim() guarantees exactly one path resumes the continuation.
    /// 7. After the continuation resumes, return the captured result or throw invalidData
    ///    if the result was unexpectedly nil (defensive; should not occur in practice).
    /// ```
    private func sink<Value: ReceivedEvent>(  // swiftlint:disable:this function_parameter_count
        publisher: some Publisher<Value, Never>,
        origin event: EventDTO,
        checkTokenExpiration: Bool,
        socketService: SocketService,
        eventsService: EventsService,
        cancellables: inout [AnyCancellable],
        file: StaticString = #file,
        line: UInt = #line
    ) async throws -> Value {
        // Owns the single-resume flag and the captured result in a Sendable container so
        // they can be safely captured by the @Sendable Task closure and Combine callbacks
        // running on different execution contexts.
        let state = ResumeState<Value>()

        // Serialize before entering the continuation: eventsService.serialize can throw but
        // is synchronous, so it cannot be called inside the non-throwing continuation closure.
        let data = try eventsService.serialize(event: event)

        // Holds the send task so it can be cancelled once the continuation resolves.
        // Declared before the try await so the defer below covers every exit path (success,
        // timeout, OperationError, and send error).
        var sendTask: Task<Void, Never>?

        // Signal cancellation to the send task on every exit path: success, timeout,
        // OperationError, and send error. This is a cooperative best-effort hint —
        // Task.cancel() sets the cancellation flag but does not forcibly terminate work;
        // the underlying socketService.send() will still complete if it does not check
        // Task.isCancelled.
        defer { sendTask?.cancel() }

        try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<(), any Error>) in
            // --- Subscription 1: expected response type ---
            // Filter by eventId *before* .timeout so the timeout measures "time to matching
            // response" and not "time to any event of this type". Without the upstream filter,
            // an unrelated concurrent event of the same type would reset the timer on every
            // emission, potentially preventing eventTimeout from ever firing.
            // DispatchQueue.main is used as the .timeout scheduler so the deadline fires on
            // the main queue regardless of which thread delivers the upstream value.
            publisher
                // swiftlint:disable:next trailing_closure
                .filter { $0.eventId == event.eventId }
                .setFailureType(to: CXoneChatError.self)
                // swiftlint:disable:next trailing_closure
                .timeout(.seconds(EventsService.responseTimeout), scheduler: DispatchQueue.main, customError: {
                    .eventTimeout
                })
                .sink { completion in
                    // receiveValue fires first when a response arrives, claiming the token.
                    // Only act on the failure completion if no path has already claimed it.
                    if case .failure(let error) = completion, state.claim() {
                        LogManager.error("Did receive error: \(error) for eventType: \(event.payload.eventType)", file: file, line: line)
                        continuation.resume(throwing: error)
                    }
                } receiveValue: { response in
                    // eventId already filtered upstream; claim the token and resume.
                    if state.claim(result: response) {
                        LogManager.info(
                            "Did receive event with same eventId: \(response.eventId) for event: \(response.realEventType?.rawValue ?? "unknown")",
                            file: file,
                            line: line
                        )
                        continuation.resume()
                    }
                }
                .store(in: &cancellables)

            // --- Subscription 2: server-side operation errors ---
            // The server can respond with an OperationError (e.g. inconsistentData) instead
            // of the expected event type. These arrive on the same publisher stream but as a
            // different concrete type, so they need a separate subscription.
            self
                .with(type: OperationError.self)
                .sink { error in
                    if error.eventId == event.eventId, state.claim() {
                        LogManager.error("Did receive error: \(error) for eventType: \(event.payload.eventType)", file: file, line: line)
                        continuation.resume(throwing: error)
                    }
                }
                .store(in: &cancellables)

            // --- Send: fired AFTER both subscriptions are stored ---
            // Previously this used `async let`, which spawns a concurrent child task that can
            // call socketService.send() — and in tests, synchronously deliver a response via
            // PassthroughSubject — before .store(in:) has been called. That dropped the event
            // and caused an intermittent 10 s timeout on CI.
            // A plain Task here is created after .store(in:), so subscriptions are guaranteed
            // to be active before the send (and any synchronous mock response) executes.
            sendTask = Task {
                do {
                    try await socketService.send(data: data, shouldCheck: checkTokenExpiration)
                } catch {
                    if state.claim() {
                        continuation.resume(throwing: error)
                    }
                }
            }
        }

        if let result = state.result {
            return result
        } else {
            throw CXoneChatError.invalidData
        }
    }
}

// MARK: - ResumeState

/// Thread-safe single-resume token for the Combine→async bridge.
///
/// Owns both the claimed flag and the captured result so that they can be safely shared
/// across the `@Sendable` `Task` closure and Combine callbacks running on different
/// execution contexts. Marked `@unchecked Sendable` because all mutable state is
/// protected by `lock`.
private final class ResumeState<Value>: @unchecked Sendable {

    // MARK: - Properties

    private let lock = NSLock()
    private var claimed = false

    /// The response value stored by the successful `claim(result:)` call, if any.
    private(set) var result: Value?

    // MARK: - Methods

    /// Atomically claims the single-resume token.
    ///
    /// - Parameter result: Optional value to store alongside the claim (used on the success path).
    /// - Returns: `true` the first time this is called; `false` on every subsequent call.
    func claim(result: Value? = nil) -> Bool {
        lock.lock()
        
        defer { lock.unlock() }
        
        guard !claimed else {
            return false
        }
        
        claimed = true
        self.result = result
        
        return true
    }
}
