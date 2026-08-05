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

/// Broadcasts ``ChatEvent`` values to all active ``AsyncStream`` consumers.
///
/// Thread-safe via ``SafeAccessContainer``. ``send(_:)`` is synchronous —
/// services do not need `await` to fire events.
final class EventBroadcaster: Sendable {
    
    // MARK: - Private
    
    private let _continuations = SafeAccessContainer<[LowercaseUUID: AsyncStream<ChatEvent>.Continuation]>([:])
    
    /// Maximum number of events buffered per subscriber before older events are dropped.
    static let streamBufferCapacity = 64
    
    // MARK: - API
    
    /// Creates a new ``AsyncStream`` subscription.
    ///
    /// Each caller receives its own independent stream. Events are broadcast to all active streams.
    /// The stream buffers at most ``streamBufferCapacity`` events for a slow consumer; older events
    /// are dropped when the buffer is full. Cancel the enclosing `Task` to stop receiving events.
    func makeStream() -> AsyncStream<ChatEvent> {
        let id = LowercaseUUID()
        let (stream, continuation) = AsyncStream.makeStream(of: ChatEvent.self, bufferingPolicy: .bufferingNewest(Self.streamBufferCapacity))

        _continuations.mutate { continuations in
            continuations[id] = continuation
            
            LogManager.trace("New stream added, total=\(continuations.count)")
        }

        continuation.onTermination = { [weak self] reason in
            self?._continuations.mutate { continuations in
                continuations.removeValue(forKey: id)
                
                LogManager.trace("Stream removed, reason=\(reason), remaining=\(continuations.count)")
            }
        }

        return stream
    }
    
    /// Sends an event to all active streams. Synchronous — safe to call from any thread.
    ///
    /// - Note: `_continuations.content` snapshots the dictionary under the lock and
    ///   releases it before any `yield` is called. A continuation cancelled between the
    ///   snapshot and the `yield` call simply no-ops — the documented behaviour of
    ///   `AsyncStream.Continuation.yield` on a finished stream.
    func send(_ event: ChatEvent) {
        let snapshot = _continuations.content
        snapshot.values.forEach { continuation in
            continuation.yield(event)
        }
    }
    
    /// Finishes all active subscriber streams immediately.
    ///
    /// Call this when the SDK session ends (e.g. ``CXoneChat/signOut()``) so that any
    /// `for await` loop waiting for an event exits cleanly instead of suspending forever.
    /// After this call, new ``makeStream()`` subscribers will work normally.
    func invalidate() {
        let snapshot = _continuations.mutate { current -> [LowercaseUUID: AsyncStream<ChatEvent>.Continuation] in
            let snap = current
            current = [:]
            return snap
        }
        
        for continuation in snapshot.values {
            continuation.finish()
        }
    }
}
