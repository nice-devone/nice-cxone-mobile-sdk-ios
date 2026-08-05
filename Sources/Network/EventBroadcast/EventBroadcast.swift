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

/// Thread-safe broadcaster that delivers received events to multiple concurrent subscribers.
///
/// Each call to ``makeStream()`` returns an independent
/// `AsyncStream<any ReceivedEvent>` that receives every event delivered via
/// ``send(_:)`` until the subscribing task is cancelled or the stream finishes.
///
/// `makeStream()` is **synchronous** so callers can subscribe before starting
/// the async consumer task, eliminating any subscription race between task
/// creation and stream registration.
///
/// Call ``invalidate()`` when the underlying connection closes to immediately
/// unblock all active `for await` loops instead of leaving them waiting until
/// a caller-side timeout fires.
final class EventBroadcast: Sendable {

    // MARK: - Internal

    /// Sentinel event yielded to all active streams by ``invalidate()``.
    ///
    /// Receiving this event in ``waitFor`` causes the scanner task to throw
    /// ``CXoneChatError/invalidData`` immediately, without waiting for the stream
    /// to be closed by ``AsyncStream/Continuation/finish()``.
    struct BroadcastInvalidatedEvent: ReceivedEvent {
        
        static var associatedEventType: EventType? { nil }
        
        var eventId: String { "" }
        var eventType: EventType? { nil }
        var postbackEventType: EventType? { nil }
    }

    // MARK: - Private state

    /// All subscriber continuations are owned by this lock, so both the
    /// container and its wrapped state are compiler-verified `Sendable` —
    /// no `@unchecked` required. Snapshots are always taken before yielding
    /// to avoid holding the lock across async operations.
    private let _continuations = SafeAccessContainer<[LowercaseUUID: AsyncStream<any ReceivedEvent>.Continuation]>([:])

    // MARK: - Methods

    /// Creates a new stream that receives all future events.
    ///
    /// The stream finishes automatically when its consuming task is cancelled.
    /// Subscription is registered synchronously, so the caller can create the
    /// consuming `Task` afterwards without missing any events.
    ///
    /// - Note: Uses the default unbounded buffer (`AsyncStream.makeStream()` with no buffering
    ///   policy). This is intentional: `waitFor` correlation streams must not drop events — a
    ///   dropped event would cause a caller to time out silently. Contrast with `EventBroadcaster`,
    ///   which uses `.bufferingNewest(64)` because UI observation can tolerate dropped events.
    func makeStream() -> AsyncStream<any ReceivedEvent> {
        let id = LowercaseUUID()
        let (stream, continuation) = AsyncStream<any ReceivedEvent>.makeStream()

        _continuations.mutate { content in
            content[id] = continuation
        }

        continuation.onTermination = { [weak self] _ in
            self?.remove(id: id)
        }

        return stream
    }

    /// Finishes all active subscriber streams immediately.
    ///
    /// Call this when the underlying WebSocket connection is reset so that any
    /// `for await` loop waiting for an event (e.g. inside ``waitFor``) exits
    /// right away instead of blocking until a caller-side timeout fires.
    /// After this call, any new ``makeStream()`` subscribers will work normally
    /// once events resume flowing.
    func invalidate() {
        // Atomically drain and clear all continuations so that concurrent
        // send() calls on a snapshot don't re-register finished continuations.
        let snapshot = _continuations.mutate { current -> [LowercaseUUID: AsyncStream<any ReceivedEvent>.Continuation] in
            let snap = current
            current = [:]
            return snap
        }

        for continuation in snapshot.values {
            continuation.yield(BroadcastInvalidatedEvent())
            continuation.finish()
        }
    }

    /// Delivers `event` to all active subscribers.
    func send(_ event: any ReceivedEvent) {
        // Snapshot under the lock before yielding to avoid holding the lock
        // during yield(), which could otherwise deadlock when onTermination
        // synchronously calls remove() on the same lock.
        for continuation in _continuations.content.values {
            continuation.yield(event)
        }
    }

}

// MARK: - Private

private extension EventBroadcast {

    func remove(id: LowercaseUUID) {
        _continuations.mutate { continuations in
            continuations.removeValue(forKey: id)
        }
    }
}
