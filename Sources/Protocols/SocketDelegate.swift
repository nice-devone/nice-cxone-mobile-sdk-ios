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
import Mockable

@Mockable
protocol SocketDelegate: AnyObject, Sendable {
    
    func didCloseConnection(unexpectedly: Bool)
    
    func didReceive(error: Error)

    func refreshToken() async throws

    func reconnect() async throws

    /// Rebuilds the WebSocket URL for an automatic reconnect, re-minting the transaction token when
    /// the cached one has expired.
    ///
    /// The reconnect MUST use a freshly-built URL rather than replaying the original one: the socket
    /// URL embeds the transaction token as a query item, and that token expires after a few minutes.
    /// Replaying the stale URL makes the gateway reject the handshake (`-1011`), so every reconnect
    /// attempt fails until the retry budget is exhausted.
    ///
    /// - Parameter forceRefresh: When `true`, mint a fresh transaction token even if the cached one is
    ///   still valid by the device clock. Used from the second reconnect attempt onwards so a token the
    ///   server has invalidated (key rotation, session cleanup, backend deploy, admin revocation, clock
    ///   skew) is replaced rather than replayed on every retry. Ignored for OAuth, whose token cannot be
    ///   silently re-minted.
    func recreateSocketURL(forceRefresh: Bool) async throws -> URL
}
