//
// Copyright (c) 2021-2024. NICE Ltd. All rights reserved.
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

/// The provider for customer related properties and methods.
public protocol CustomerProvider {
    
    /// The customer currently using the app.
    ///
    /// - Returns: Returns customer if it is set. Otherwise; returns `nil`.
    func get() -> CustomerIdentity?
    
    /// Sets the customer currently using the app.
    ///
    /// - Parameter customer: The customer. Might be `nil`.
    func set(_ customer: CustomerIdentity?)
    
    /// Registers a device to be used for push notifications.
    ///
    /// - Parameter token: The unique token for the device to be registered.
    func setDeviceToken(_ token: String)
    
    /// Registers a device to be used for push notifications.
    ///
    /// - Parameter tokenData: The unique token for the device to be registered.
    func setDeviceToken(_ tokenData: Data)
    
    /// Sets the authorization code from an OAuth provider in order to authorize the customer with authentication code.
    ///
    /// This code must be provided before ``connect(environment:brandId:channelId:)`` or  ``connect(chatURL:socketURL:brandId:channelId:)``.
    ///     if the channel is configured to use OAuth.
    ///
    /// - Parameter code: The authorization code from an OAuth provider.
    ///
    /// - Note: This is not an access token. This is the authorization code that one would use to obtain an access token.
    func setAuthorizationCode(_ code: String)
    
    /// Sets the code verifier to be used for OAuth if the OAuth provider uses PKCE.
    ///
    /// This must be passed so that CXone can retrieve an auth token.
    ///
    /// - Parameter verifier: The generated code verifier.
    func setCodeVerifier(_ verifier: String)
    
    /// Sets the name to be used for the customer in the chat.
    /// 
    /// - Parameters:
    ///   - firstName: The first name for the customer.
    ///   - lastName: The last name for the customer.
    func setName(firstName: String, lastName: String)
}
