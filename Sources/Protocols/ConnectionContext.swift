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
protocol ConnectionContext: AnyObject, Sendable {
    
    // periphery:ignore - false positive
    var keychainService: any KeychainStorage { get }
    
    var userDefaultsService: UserDefaultsService { get }
    
    /// The token of the device for push notifications.
    var deviceToken: String? { get set }
    
    /// The code used for login with OAuth.
    var authorizationCode: String { get set }
    
    /// The code verifier used for OAuth (if PKCE is required).
    var codeVerifier: String { get set }

    /// The JWT access token provided by the integrator for implicit OAuth flow. In-memory only — not Keychain-backed.
    var connectionToken: String? { get set }

    /// The absolute expiry of ``connectionToken`` for the implicit OAuth flow, or `nil` if none is set. In-memory only.
    var connectionTokenExpiresAt: Date? { get set }

    /// Listener invoked to obtain a fresh connection token for the implicit OAuth flow, or `nil` if not registered. In-memory only.
    var tokenDelegateListener: TokenDelegateListener? { get set }

    /// The unique contact id for the last loaded thread.
    var contactId: String? { get set }
    
    /// The current channel configuration for currently connected CXone session.
    var channelConfig: ChannelConfigurationDTO { get set }
    
    /// The id of the brand for the chat.
    var brandId: Int { get set }
    
    /// The id of the channel for the chat.
    var channelId: String { get set }
    
    /// The id generated for the destination.
    var destinationId: String { get set }
    
    /// The environment/location to use for CXone.
    var environment: EnvironmentDetails { get set }
    
    /// An object that coordinates a group of related, network data transfer tasks.
    var session: URLSessionProtocol { get }

    var chatState: ChatState { get set }
    
    var visitorId: String? { get set }

    var visitDetails: CurrentVisitDetails? { get set }

    var customer: CustomerIdentityDTO? { get set }

    /// The current transaction token for WebSocket authentication. Has a short lifetime (~10 minutes).
    var transactionToken: TransactionTokenDTO? { get set }
    
    var persistedSetPositionInQueueEvent: SetPositionInQueueEventDTO? { get set }
    
    var lastPageViewed: PageViewEventDTO? { get set }
    
    func clear()
}

// MARK: - Helpers

extension ConnectionContext {

    var visitId: String? {
        visitDetails?.visitId
    }

    /// The lead time before ``connectionTokenExpiresAt`` at which the implicit connection token is treated as expiring.
    static var connectionTokenExpiryBuffer: TimeInterval {
        10 // seconds
    }

    /// Whether the implicit-flow connection token (JWT) is expired or will expire within ``connectionTokenExpiryBuffer``.
    ///
    /// A backend rejection of an already-open socket is not observable, so the SDK relies on the expiry
    /// supplied via ``CustomerProvider/setConnectionToken(_:expiresAt:)`` (and refreshed values from the
    /// token delegate) to detect this before sending an outbound event. Returns `false` when no expiry is
    /// set (nothing to compare against) — i.e. a token whose expiry is unknown is never refreshed proactively.
    ///
    /// The reference time comes from ``Date/provide()``, so the expiry boundary can be tested deterministically
    /// by injecting a fixed ``DateProvider`` via ``Date/provider``.
    var isConnectionTokenExpiring: Bool {
        guard let connectionTokenExpiresAt else {
            return false
        }

        return Date.provide().addingTimeInterval(Self.connectionTokenExpiryBuffer) >= connectionTokenExpiresAt
    }

    /// Whether this is an implicit-OAuth session whose connection token is expiring and therefore needs a
    /// proactive refresh before the next outbound operation.
    ///
    /// Shared by the connect and message-send paths so the "is a proactive refresh due?" rule lives in one
    /// place. Callers still decide independently how to handle a missing token delegate listener.
    var isImplicitConnectionTokenExpiring: Bool {
        authenticationType == .oAuthImplicit && isConnectionTokenExpiring
    }

    /// The cached transaction token if it is still usable (present and not expired), or `nil` if a fresh one
    /// must be requested. Centralizes the reuse rule shared by the connect and transaction-token exchange paths.
    var reusableTransactionToken: TransactionTokenDTO? {
        guard let transactionToken, !transactionToken.isExpired else {
            return nil
        }

        return transactionToken
    }

    /// Whether an outbound event should trigger a proactive credential refresh before it is sent: an expired
    /// explicit-PKCE access token, or an expiring implicit connection token. Owning the policy here keeps the
    /// socket layer from accreting auth knowledge and prevents the two triggers from drifting apart.
    var needsProactiveTokenRefresh: Bool {
        transactionToken?.accessToken?.isExpired == true || isImplicitConnectionTokenExpiring
    }

    /// The effective authentication mode at runtime, combining channel configuration with current credentials.
    var authenticationType: AuthenticationTypeDTO {
        switch channelConfig.authenticationType {
        case .anonymous:
            return .anonymous
        case .securedCookie:
            return .securedCookie
        case .thirdPartyOAuth:
            return connectionToken?.nilIfEmpty() != nil ? .oAuthImplicit : .oAuthExplicit
        }
    }

    /// Enum representing different modes for chat functionality.
    var chatMode: ChatMode {
        if channelConfig.liveChatAvailability.isChannelLiveChat {
            return .liveChat
        } else if channelConfig.settings.hasMultipleThreadsPerEndUser {
            return .multithread
        } else {
            return .singlethread
        }
    }
}
