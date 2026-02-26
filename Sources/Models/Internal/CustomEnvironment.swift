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

/// A custom environment with user-defined URLs for both chat and socket connections.
struct CustomEnvironment: EnvironmentDetails {
    
    // MARK: - Properties

    let chatURL: String

    let socketURL: String

    var loggerURL: String

    let tokenURL: String

    // MARK: - Init
    init(chatURL: String, socketURL: String, loggerURL: String?, tokenURL: String?) {
        self.chatURL = chatURL
        self.socketURL = socketURL
        self.loggerURL = loggerURL ?? Self.evaluateLoggerUrl(from: chatURL) ?? ""
        self.tokenURL = tokenURL ?? Self.evaluateTokenServerUrl(from: chatURL) ?? ""
    }
}

// MARK: - Helpers

private extension CustomEnvironment {
    private static let loggerUrlSuffix = "logger-public"
    private static let channelsPath = "channels"
    private static let appPath = "app"
    private static let digitalOAuthPrefix = "digital-oauth"

    /// Evaluates the logger URL based on the provided chat URL.
    ///
    /// This method converts the chat URL (e.g. "https://channels-eu1-qa.brandembassy.com/chat/")
    /// to a logger URL (e.g. "https://app-eu1-qa.brandembassy.com/logger-public").
    ///
    /// - Parameter chatUrl: The URL of the chat service.
    /// - Returns: A string representing the logger URL if the chat URL is valid; otherwise, returns nil.
    static func evaluateLoggerUrl(from chatUrl: String) -> String? {
        guard let url = URL(string: chatUrl) else {
            LogManager.error("Invalid chat URL: \(chatUrl)")
            return nil
        }

        let result = url
            .deletingLastPathComponent() // Extract the base URL without the trailing slash "/chat"
            .absoluteString // convert to String
            .replacingOccurrences(of: Self.channelsPath, with: Self.appPath) // replace "channels" with "app"
            .appending(Self.loggerUrlSuffix) // append "/logger-public"
        // Verify the constructed URL
        if result.range(of: #"^https:\/\/app[^\/]+\/logger-public$"#, options: .regularExpression) != nil {
            return result
        } else {
            LogManager.error("Invalid logger URL constructed from chat URL: \(result)")
            return nil
        }
    }

    /// Evaluates the transaction token server base URL from the provided chat URL.
    ///
    /// Converts chat URLs to transaction token server URLs by replacing "channels" with "digital-oauth".
    /// The returned URL is a base URL; the endpoint path `/oauth/token` is appended by the service layer.
    ///
    /// For example:
    /// - "https://channels-de-eu1.niceincontact.com/chat" → "https://digital-oauth-de-eu1.niceincontact.com/"
    /// - "https://channels-eu1-qa.brandembassy.com/chat" → "https://digital-oauth-eu1-qa.brandembassy.com/"
    ///
    /// - Parameter chatUrl: The URL of the chat service.
    /// - Returns: A string representing the transaction token server base URL if the chat URL is valid; otherwise, returns nil.
    static func evaluateTokenServerUrl(from chatUrl: String) -> String? {
        guard let url = URL(string: chatUrl) else {
            LogManager.error("Invalid chat URL: \(chatUrl)")
            return nil
        }

        var result = url
            .deletingLastPathComponent() // Extract the base URL without the trailing slash "/chat"
            .absoluteString // convert to String
            .replacingOccurrences(of: Self.channelsPath, with: Self.digitalOAuthPrefix) // replace "channels" with "digital-oauth"
            .trimmingCharacters(in: CharacterSet(charactersIn: "/"))

        result.append("/") // append single trailing slash

        // Verify the constructed URL
        if result.range(of: #"^https:\/\/digital-oauth[^\/]+\/$"#, options: .regularExpression) != nil {
            return result
        } else {
            LogManager.error("Invalid transaction token server URL constructed from chat URL: \(result)")
            return nil
        }
    }
}
