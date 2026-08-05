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

// MARK: - Task<Never, Never>

extension Task where Success == Never, Failure == Never {
    
    /// Suspends the current task for the given number of seconds.
    ///
    /// - Note: Cancellation is **propagated** as `CancellationError` (the standard
    ///   `Task.sleep(nanoseconds:)` behaviour). This is deliberate: a caller that relies on a
    ///   real delay — e.g. reconnect exponential backoff — must be able to tell when the sleep
    ///   was cut short rather than have it silently return as if the full interval had elapsed.
    ///   Callers that intentionally want to ignore cancellation and fall through to their own
    ///   `Task.isCancelled` check should call this with `try?`.
    static func sleep(seconds: Double) async throws {
        // Guard against non-finite or non-positive intervals: converting them to `UInt64` would
        // trap at runtime. Treat them as "no delay" while still honouring cancellation.
        guard seconds.isFinite, seconds > 0 else {
            try Task.checkCancellation()

            return
        }

        // Clamp before converting: `UInt64(x)` traps when `x` exceeds `UInt64.max`
        // (~584 years expressed in nanoseconds), so a very large finite `seconds` would crash
        // instead of sleeping. Clamping keeps the helper total over its whole input domain.
        let nanoseconds = seconds * TimeInterval.secondInNanoseconds
        let duration = nanoseconds >= Double(UInt64.max) ? UInt64.max : UInt64(nanoseconds)

        try await Task.sleep(nanoseconds: duration)
    }
}

// MARK: - Task<_, Error>

extension Task where Failure == Error {
    
    @discardableResult
    static func retrying(
        priority: TaskPriority? = nil,
        attempts: Int = 3,
        operation: @Sendable @escaping () async throws -> Success
    ) -> Task {
        Task(priority: priority) {
            for attempt in 0..<attempts {
                do {
                    return try await operation()
                } catch {
                    if case .sdkVersionNotSupported = error as? CXoneChatError {
                        // This error indicates that the SDK version is not supported so it should not be retried.
                        throw error
                    }
                    
                    let delay = TimeInterval.calculateExponentialBackoffDelay(attempt: attempt)

                    // The sleep swallows its own cancellation (via `try?`) so a cut-short backoff
                    // isn't misreported as an operation failure. The explicit `checkCancellation()`
                    // below is what actually aborts a cancelled retry loop — without it, a cancelled
                    // task would keep invoking `operation()` for every remaining attempt.
                    try? await Task<Never, Never>.sleep(seconds: delay)

                    try Task<Never, Never>.checkCancellation()

                    continue
                }
            }
            
            try Task<Never, Never>.checkCancellation()
            
            return try await operation()
        }
    }
}
