//
// Copyright (c) 2021-2023. NICE Ltd. All rights reserved.
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

/// an object capable of performing OAuth authentication
protocol OAuthenticator {

    // MARK: - Type Aliases

    /// Invoked when an authentication request completes
    ///
    /// - parameters:
    ///     - cancelled: true iff the request was cancelled
    ///     - result: if the request was successful, will contain details of the success
    typealias OAAuthenticationHandler = (cancelled: Bool, result: OAResult?)

    // MARK: - Properties

    /// user presentable name of authenticator
    var authenticatorName: String { get }

    // MARK: - Methods

    /// attempt OAuth authentication using this authenticator
    ///
    /// - Parameter withChallenge: Challenge string
    /// - Returns: Routine to invoke as result of the request
    func authorize(withChallenge: String) async throws -> OAAuthenticationHandler

    /// attempt to logout any cached user results
    ///
    /// - parameters:
    ///     - onCompletion: routine to invoke on completion of request
    func signOut() async throws

    /// handle an open url request from the application, this may be required to complete
    /// some varieties of OAuth
    ///
    /// - parameters:
    ///     - url: url being opened
    ///     - sourceApplication: name of application originating request
    func handleOpen(url: URL, sourceApplication: String?) -> Bool
}
