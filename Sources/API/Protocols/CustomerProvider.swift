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

/// The provider for customer related properties and methods.
@Mockable
public protocol CustomerProvider: Sendable {
    
    /// The customer currently using the app.
    ///
    /// - Returns: Returns customer if it is set. Otherwise; returns `nil`.
    func get() -> CustomerIdentity?
    
    /// Sets the customer currently using the app.
    ///
    /// If you set your customer ID, you must ensure that it is unique and that it is not used by any other customer.
    ///
    /// - Note: Setting your own Customer ID may result in security vulnerabilities.
    /// It is recommended to use the customer ID provided by the SDK. If you want to update the customer name, use the ``setName(firstName:lastName:)`` method.
    ///
    /// - Warning: This method must be called before SDK initialization via ``ConnectionProvider/prepare(environment:brandId:channelId:)``.
    ///
    /// - Parameter customer: The customer identity. Can be `nil`.
    ///
    /// - Throws: ``CXoneChatError/illegalChatState`` if the chat is already initialized.
    func set(customer: CustomerIdentity?) throws
    
    /// Registers a device to be used for push notifications.
    ///
    /// - Parameter token: The unique token for the device to be registered.
    func setDeviceToken(_ token: String)
    
    /// Registers a device to be used for push notifications.
    ///
    /// - Parameter tokenData: The unique token for the device to be registered.
    func setDeviceToken(_ tokenData: Data)
    
    /// Provides a connection token and its expiry to the SDK for the implicit OAuth flow.
    ///
    /// Call this before ``ConnectionProvider/connect()`` with the JWT obtained from your OAuth provider,
    /// and again whenever the SDK reports the token is no longer valid by throwing
    /// ``CXoneChatError/invalidAccessToken`` from an outbound method — obtain a fresh token, provide it
    /// here, and retry the operation that threw.
    ///
    /// The SDK uses `expiresAt` to detect an expired token before sending an event (a backend rejection of
    /// an already-open socket is not otherwise observable) and to signal you to refresh in time. The SDK
    /// never sources tokens on its own — it always obtains them from the integrator, either via this call
    /// or via the listener registered with ``setTokenDelegateListener(_:)``.
    ///
    /// - Parameters:
    ///   - token: A valid JWT obtained from the OAuth provider.
    ///   - expiresAt: The absolute time at which `token` expires (e.g. derived from the provider's `expires_in`).
    func setConnectionToken(_ token: String, expiresAt: Date)

    /// Registers a listener the SDK calls to obtain a fresh connection token for the implicit OAuth flow.
    ///
    /// When registered, the SDK requests a fresh token automatically — shortly before the current one expires
    /// (``TokenRequestReason/tokenExpired``) or after the backend rejects it at connect (``TokenRequestReason/tokenInvalid``).
    /// It pauses the pending operation, obtains the token, and resumes it, so outbound events are not interrupted.
    /// Concurrent operations queue behind a single refresh. The listener obtains a token from your OAuth provider
    /// and returns an ``OAuthToken``; if it throws, the pending operation fails with ``CXoneChatError/invalidAccessToken``.
    ///
    /// The initial token is still provided via ``setConnectionToken(_:expiresAt:)``; this listener handles
    /// subsequent refreshes. When no listener is registered, an expired token surfaces reactively as
    /// ``CXoneChatError/invalidAccessToken`` from the outbound method.
    ///
    /// - Parameter listener: The token listener, or `nil` to remove a previously registered one.
    func setTokenDelegateListener(_ listener: TokenDelegateListener?)

    /// Sets the authorization code for the explicit OAuth flow (PKCE).
    ///
    /// Call this before ``ConnectionProvider/connect()`` when using an explicit OAuth flow.
    ///
    /// - Important: This setter stores the value without validating flow availability. While the
    ///   explicit flow is unavailable, the failure surfaces later — ``ConnectionProvider/connect()``
    ///   throws ``CXoneChatError/featureUnavailable(_:)`` during the token exchange.
    ///
    /// - Parameter code: The authorization code received from the OAuth provider.
    func setAuthorizationCode(_ code: String)

    /// Sets the PKCE code verifier for the explicit OAuth flow.
    ///
    /// Call this before ``ConnectionProvider/connect()`` when using an explicit OAuth flow.
    ///
    /// - Important: This setter stores the value without validating flow availability. While the
    ///   explicit flow is unavailable, the failure surfaces later — ``ConnectionProvider/connect()``
    ///   throws ``CXoneChatError/featureUnavailable(_:)`` during the token exchange.
    ///
    /// - Parameter verifier: The PKCE code verifier generated locally before the authorization request.
    func setCodeVerifier(_ verifier: String)

    /// Sets the name to be used for the customer in the chat.
    /// 
    /// - Parameters:
    ///   - firstName: The first name for the customer.
    ///   - lastName: The last name for the customer.
    func setName(firstName: String, lastName: String)
}
