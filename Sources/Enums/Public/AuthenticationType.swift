//
// Copyright (c) 2021-2025. NICE Ltd. All rights reserved.
//
// Licensed under the NICE License;
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//    https://github.com/nice-devone/nice-cxone-mobile-sdk-ios/blob/main/LICENSE
//
// TO THE EXTENT PERMITTED BY APPLICABLE LAW, THE CXONE MOBILE SDK IS PROVIDED ON
// AN “AS IS” BASIS. NICE HEREBY DISCLAIMS ALL WARRANTIES AND CONDITIONS, EXPRESS
// OR IMPLIED, INCLUDING (WITHOUT LIMITATION) WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE, NON-INFRINGEMENT, AND TITLE.
//

import Foundation

/// Authentication type for chat connection.
///
/// Defines the authentication method used when establishing a connection to CXone services.
public enum AuthenticationType: String, Codable {
    
    /// Anonymous authentication mode.
    ///
    /// Allows custom customer identity to be provided (e.g., phone number).
    /// This mode is currently the default for existing clients.
    case anonymous
    
    /// Secured cookie authentication mode.
    ///
    /// Backend generates customer identity for enhanced security.
    /// This mode requires transaction token exchange before WebSocket connection.
    /// Default for new clients (post-25.4 release).
    case securedCookie
    
    /// Third-party OAuth provider authentication mode.
    ///
    /// Uses authorization code and code verifier for authentication.
    /// Requires configuration with supported OAuth providers (e.g., AWS Cognito).
    case thirdPartyOAuth
}
