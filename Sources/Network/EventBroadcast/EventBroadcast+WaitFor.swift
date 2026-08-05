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

import Foundation

extension EventBroadcast {

    /// Subscribes to events, sends an outgoing request, then awaits a matching response event.
    ///
    /// Subscribes to the broadcast *before* the request is sent to avoid missing responses that
    /// arrive before the caller starts iterating.  The response stream is abandoned once a match
    /// is found or an error is delivered.
    ///
    /// - Parameters:
    ///   - dataType: The concrete `ReceivedEvent` type to match and return.
    ///   - eventType: Optional event-type filter applied before the type cast.
    ///   - event: The outgoing `EventDTO` whose `eventId` is used for correlation.
    ///   - checkTokenExpiration: Whether to refresh the access token before sending.
    ///   - socketService: Used to send the request.
    ///   - eventsService: Used to serialise `event` into `Data`.
    ///   - onRegistered: **Do not use in production code.** Test-only hook called synchronously
    ///     right after `makeStream()` registers the continuation. Allows tests to call
    ///     `broadcast.send(_:)` or `broadcast.invalidate()` at the exact moment the stream is
    ///     ready, eliminating the child-task scheduling race on multi-core schedulers. Pass `nil`
    ///     (the default) in all non-test call sites.
    ///
    /// - Returns: The first matching `Type` response with the same `eventId`.
    ///
    /// - Throws: ``CXoneChatError/eventTimeout`` if no matching event arrives within `EventsService.responseTimeout`.
    /// - Throws: ``CXoneChatError/invalidData`` if the stream ends without a match.
    /// - Throws: ``OperationError`` if the server returns an operation error with the same `eventId`.
    /// - Throws: ``ServerError`` if the server returns a transport-level error with the same `eventId`.
    @discardableResult
    func waitFor<Type: ReceivedEvent>(
        _ dataType: Type.Type,
        eventType: EventType? = nil,
        origin event: EventDTO,
        checkTokenExpiration: Bool = true,
        socketService: SocketService,
        eventsService: EventsService,
        onRegistered: (@Sendable () -> Void)? = nil,
        file: StaticString = #file,
        line: UInt = #line
    ) async throws -> Type {
        // Subscribe BEFORE sending so no response is missed.
        // makeStream() is synchronous and registers the continuation immediately,
        // ensuring any event dispatched after this point is buffered for the stream
        // even if the consuming `for await` loop has not started iterating yet.
        let stream = makeStream()
        // test hook — see parameter docs
        onRegistered?()
        // Serialize BEFORE starting the concurrent send task so that a
        // serialization failure throws immediately to the caller, rather than
        // being captured inside an `async let` and potentially swallowed if the
        // task group itself throws first (e.g. timeout or OperationError).
        let requestData = try eventsService.serialize(event: event)
        // Start the send concurrently with the stream iteration below.
        // Using an unstructured Task lets the network request fly while we are
        // already listening for the response, and makes the task Sendable so it
        // can be captured by the send-guard child task inside the group.
        let sendTask = Task<Void, Error> {
            try await socketService.send(data: requestData, shouldCheck: checkTokenExpiration)
        }
        
        // Cancel the unstructured send task on all exits (success, error, cancellation)
        // so it never outlives the waitFor call and leaks a network operation.
        defer { sendTask.cancel() }
        // Race three child tasks: stream scanner, timeout guard, and send guard.
        // Whichever finishes first wins; the others are cancelled immediately.
        return try await withThrowingTaskGroup(of: Type.self) { group in
            // Task 1 — stream scanner.
            group.addTask {
                try await self.scanStream(stream, eventType: eventType, origin: event, file: file, line: line)
            }

            // Task 2 — timeout guard.
            // Throws `eventTimeout` after `EventsService.responseTimeout` seconds,
            // which causes the task group to cancel the scanner task and propagate
            // the error to the caller.
            group.addTask {
                // `try?` intentionally ignores cancellation of the sleep itself; the
                // explicit `Task.checkCancellation()` below is what turns cancellation
                // (e.g. because the scanner task already succeeded) into a clean exit.
                // Without this check, cancellation would let eventTimeout fire falsely.
                try? await Task.sleep(seconds: EventsService.responseTimeout)

                try Task.checkCancellation()

                LogManager.error("Did receive timeout for eventType: \(event.payload.eventType)", file: file, line: line)

                throw CXoneChatError.eventTimeout
            }

            // Task 3 — send guard.
            // Races the in-flight send so that an immediate failure (e.g. socket
            // disconnected before the request left the device) surfaces right away
            // instead of being masked as `eventTimeout` after the full wait period.
            // If the send succeeds, this task parks until the group cancels it so it
            // cannot win the race ahead of the real response from Task 1.
            group.addTask {
                try await sendTask.value

                // Poll until the group cancels this task after Task 1 or Task 2 wins.
                //
                // IMPORTANT: `try?` deliberately ignores cancellation of the sleep here so
                // this task does NOT throw immediately when cancelled. This prevents a race
                // where Task 3's CancellationError could be picked up by group.next() ahead of
                // Task 1's real result or Task 2's timeout. Task 3 only stops spinning once
                // isCancelled is true, which is set only after group.next() has already
                // returned the winning result.
                while !Task.isCancelled {
                    try? await Task.sleep(seconds: EventsService.responseTimeout)
                }

                throw CancellationError()
            }

            // First task to complete (match or error) wins; cancel the others
            // to stop the timeout timer, abort the stream scan, and release the
            // send-monitor task.
            // group.next() returns nil only when the group has no tasks left,
            // which cannot happen here — all tasks were unconditionally added above.
            guard let value = try await group.next() else {
                group.cancelAll()

                throw CXoneChatError.invalidData
            }

            group.cancelAll()

            return value
        }
    }
}

// MARK: - Private

private extension EventBroadcast {

    /// Iterates `stream` until a matching response event is found, a server-side error is
    /// received for the same `eventId`, or the stream is exhausted via ``invalidate()``.
    func scanStream<Type: ReceivedEvent>(
        _ stream: AsyncStream<any ReceivedEvent>,
        eventType: EventType?,
        origin event: EventDTO,
        file: StaticString,
        line: UInt
    ) async throws -> Type {
        for await received in stream {
            if received is BroadcastInvalidatedEvent {
                throw CXoneChatError.invalidData
            }

            if let error = received as? OperationError, error.eventId == event.eventId {
                LogManager.error("Did receive operation error: \(error) for eventType: \(event.payload.eventType)", file: file, line: line)
                throw error
            } else if let error = received as? ServerError, error.eventId == event.eventId {
                LogManager.error("Did receive server error: \(error) for eventType: \(event.payload.eventType)", file: file, line: line)
                throw error
            } else if let eventType, received.realEventType != eventType {
                continue
            }

            guard let typed = received as? Type, typed.eventId == event.eventId else {
                continue
            }

            LogManager.trace(
                "Did receive event with same eventId: \(typed.eventId) for event: \(typed.realEventType?.rawValue ?? "unknown")",
                file: file,
                line: line
            )

            return typed
        }

        throw CXoneChatError.invalidData
    }
}
