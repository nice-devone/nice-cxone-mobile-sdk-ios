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

/// The reason the SDK is requesting a fresh connection token from the integrator.
///
/// Passed to the listener registered via ``CustomerProvider/setTokenDelegateListener(_:)`` so integrators
/// can log or branch on the context (e.g. silent refresh vs. full re-login). Implementations are free to
/// ignore the reason and always perform the same token-fetch action.
public enum TokenRequestReason: Sendable, Equatable {

    /// The current token expired (or is about to) — the SDK requests a fresh one before it becomes unusable.
    case tokenExpired

    /// The backend rejected the token at connect time (HTTP 401); a fresh one is required to establish the session.
    case tokenInvalid
}
