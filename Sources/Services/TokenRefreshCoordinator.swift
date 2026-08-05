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

/// Ensures that at most one implicit-flow token refresh is in flight at any given time.
///
/// When several outbound operations observe an expiring connection token concurrently, the first caller
/// runs the refresh and every subsequent caller awaits the same in-flight operation instead of triggering
/// its own. This prevents a thundering herd of redundant token-delegate calls while keeping the call site
/// simple: wrap the refresh in ``refresh(force:_:)`` before each send.
actor TokenRefreshCoordinator {

    // MARK: - Properties

    /// The currently running refresh, or `nil` when no refresh is in progress.
    private var inFlight: Task<String, Error>?

    // MARK: - Methods

    /// Runs `operation` as the single in-flight refresh, or awaits the existing one, returning the
    /// refreshed transaction-token value.
    ///
    /// When `force` is `false` (a proactive, expiry-driven refresh) and a refresh is already running, this
    /// call awaits that in-flight result and returns it without invoking `operation` again. Otherwise it
    /// starts `operation`, stores it as the new in-flight refresh, and clears the slot once it finishes so
    /// the next expiry window can refresh again.
    ///
    /// - Parameters:
    ///   - force: Pass `true` for a reactive refresh (the backend rejected the current token). A rejected
    ///     token must never be satisfied by another caller's in-flight — possibly proactive — result, so a
    ///     forced refresh always runs its own `operation` and becomes the new in-flight for later joiners.
    ///   - operation: The refresh work to perform when this call does not join an existing refresh.
    /// - Returns: The refreshed transaction-token value produced by the in-flight refresh this call ran or joined.
    /// - Throws: Any error thrown by `operation`; propagated to every awaiting caller.
    func refresh(force: Bool = false, _ operation: @escaping @Sendable () async throws -> String) async throws -> String {
        if !force, let inFlight {
            return try await inFlight.value
        }

        // A forced refresh replaces (rather than joins) any in-flight proactive refresh, so a rejected token
        // is never satisfied by a stale in-flight result. The displaced task is intentionally left to run to
        // completion — its own caller still awaits and consumes its value; cancelling it would fail that
        // caller. The cost is one redundant refresh in the rare forced-during-proactive race, not correctness.
        let task = Task {
            try await operation()
        }
        inFlight = task

        defer {
            // Only clear the slot if it is still this task — a later forced refresh may have replaced it.
            if inFlight == task {
                inFlight = nil
            }
        }

        return try await task.value
    }
}
