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

/// Response from the token endpoint for a `grant_type: refresh_token` exchange.
///
/// Unlike ``TransactionTokenDTO``, this response carries no transaction token — only the refreshed
/// OAuth access token. Minting a new transaction token from it requires a second, separate exchange
/// through the implicit-grant endpoint.
struct RefreshGrantResponseDTO: Equatable, Sendable {

    // MARK: - Properties

    /// The refreshed OAuth access token, or `nil` if the 2xx response omitted the `thirdParty` block.
    /// A rejected refresh (non-2xx) never reaches decoding — it throws before this type is constructed.
    let accessToken: AccessTokenDTO?
}

// MARK: - Codable

extension RefreshGrantResponseDTO: Codable {

    enum CodingKeys: String, CodingKey {
        case accessToken = "thirdParty"
    }
}
