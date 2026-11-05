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

/// The token endpoint rejected the credential the SDK presented for a grant.
///
/// Internal on purpose: what a rejection *means* to an integrator depends on which credential was
/// refused, and only the caller knows that. A rejected refresh token means the session is gone
/// (``CXoneChatError/invalidRefreshToken(_:)``), a rejected implicit JWT means the delegate should mint
/// another (``CXoneChatError/invalidAccessToken``), and for the remaining authentication types there is
/// no recovery to attempt at all. Carrying the rejection as its own type lets ``TransactionTokenService``
/// classify the response once — where the body, and so the backend's description, is still in scope —
/// and lets each caller in ``ConnectionService`` map it to the outcome its own flow documents.
///
/// Every call site that can surface this to an integrator maps it to a ``CXoneChatError`` first; it must
/// never escape through public API.
struct TokenRejectionError: Error, Sendable {

    // MARK: - Properties

    /// The HTTP status the endpoint answered with — invariantly the rejection status, since that is the only
    /// status this type is ever constructed for.
    ///
    /// Carried rather than re-derived because the call sites that cannot recover from a refusal forward it
    /// into ``CXoneChatError/transactionTokenRequestFailed(statusCode:)``, so an integrator still sees the
    /// status the endpoint actually answered with. Do not re-test it to decide whether this *is* a
    /// rejection — its existence already settles that.
    let statusCode: Int

    /// The backend's own description of the rejection, when its response body carried one.
    let message: String?

    /// Status and cause in one piece, for the log lines that report a refusal.
    ///
    /// Safe to log: ``TokenErrorResponseDTO/message`` is a fixed string belonging to the backend's error
    /// code, not anything derived from the credential that was presented.
    var logDescription: String {
        "HTTP \(statusCode): \(message ?? "no description")"
    }
}
