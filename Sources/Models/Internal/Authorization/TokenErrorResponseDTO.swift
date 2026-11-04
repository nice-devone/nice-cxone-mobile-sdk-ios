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

/// The token endpoint's failure body, as returned alongside a 400, 403 or 404 response.
///
/// The endpoint answers a failed grant with a flat `{ "message": ..., "errorCode": ... }` object;
/// a payload-validation failure (422) uses a different, nested `errors` shape that this type
/// deliberately does not model, since a validation failure means the SDK built a malformed request
/// rather than the session having gone bad.
///
/// Only a **400** ever carries a refused *credential*. The other two statuses describe the caller or
/// the channel rather than the token presented — 403 reports a blocked IP or a captcha requirement,
/// 404 an unknown brand/channel configuration (or, on an unknown route, an empty non-JSON body that
/// simply fails to decode). They are still decoded, so their cause reaches a log, but none of them can
/// mean the session must be re-authenticated.
///
/// Both properties are optional so a rejection that arrives with an unexpected or empty body still
/// decodes rather than turning a useful error into a decode failure.
struct TokenErrorResponseDTO: Equatable, Sendable {

    // MARK: - Properties

    /// The backend's human-readable description of the failure.
    ///
    /// Note this is a fixed string belonging to ``errorCode`` rather than anything the OAuth provider
    /// said, and it is not always accurate for the case at hand — `missing_required_parameters`, for
    /// example, always names `brandId, channelId` even when both were supplied. Treat it as a
    /// diagnostic hint for the integrator, never as a value to branch on.
    let message: String?

    /// The stable, machine-readable cause — for example `third_party_token_rejected` for a refresh
    /// token the provider has rejected, versus `third_party_unavailable` for a provider that is merely
    /// unreachable.
    ///
    /// This is the field the SDK branches on to tell a dead credential apart from the other causes that
    /// share its status: only the former means the session cannot be recovered without re-authenticating.
    /// See ``TransactionTokenService``'s rejection classification.
    let errorCode: String?
}

// MARK: - Codable

extension TokenErrorResponseDTO: Codable {

    enum CodingKeys: String, CodingKey {
        case message
        case errorCode
    }
}
