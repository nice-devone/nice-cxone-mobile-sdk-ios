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

/// An OAuth access token and its expiry, returned by the token delegate for the implicit OAuth flow.
///
/// Returned from the listener registered via ``CustomerProvider/setTokenDelegateListener(_:)`` so the SDK
/// can both use the token for the connection and track when it expires to request a fresh one in time.
public struct OAuthToken: Sendable, Equatable {

    // MARK: - Properties

    /// The raw JWT / access token string obtained from the OAuth provider.
    public let accessToken: String

    /// The absolute time at which ``accessToken`` expires.
    ///
    /// The SDK uses this value to request a fresh token shortly before the current one expires — the
    /// proactive refresh that keeps the implicit-flow session alive. The expiry is required so proactive
    /// refresh always functions; a token whose expiry is unknown would silently opt out of it.
    public let expiresAt: Date

    // MARK: - Init

    /// Creates an OAuth token.
    ///
    /// - Parameters:
    ///   - accessToken: The raw JWT / access token string.
    ///   - expiresAt: The absolute expiry time of the token.
    public init(accessToken: String, expiresAt: Date) {
        self.accessToken = accessToken
        self.expiresAt = expiresAt
    }
}

/// A listener the SDK invokes to obtain a fresh ``OAuthToken`` for the implicit OAuth flow.
///
/// Register it via ``CustomerProvider/setTokenDelegateListener(_:)``. The SDK calls the listener shortly
/// before the current connection token expires (or after the backend rejects it), passing a
/// ``TokenRequestReason``. The listener obtains a fresh token from the OAuth provider and returns it; the
/// SDK applies the token and resumes the operation that needed it. If the listener throws, the operation
/// fails with ``CXoneChatError/invalidAccessToken``.
public typealias TokenDelegateListener = @Sendable (TokenRequestReason) async throws -> OAuthToken
