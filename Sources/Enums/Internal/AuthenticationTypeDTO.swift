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

/// Runtime authentication type derived from channel configuration and current connection credentials.
///
/// Unlike `AuthenticationType` (which reflects channel configuration), this enum represents the
/// effective authentication mode at runtime by also considering which credentials the integrator
/// has provided. Use `ConnectionContext.authenticationType` to access the current value.
enum AuthenticationTypeDTO {
    case anonymous
    case securedCookie
    /// Implicit OAuth flow — integrator has provided a JWT via `setConnectionToken()`.
    case oAuthImplicit
    /// Explicit PKCE flow — integrator has provided an authorization code and code verifier,
    /// or the channel is `thirdPartyOAuth` but no implicit JWT has been set.
    case oAuthExplicit
}
