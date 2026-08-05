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

/// Service for transaction token exchange with the backend.
final class TransactionTokenService: Sendable {
    
    // MARK: - Properties
    
    private let connectionContext: ConnectionContext
    
    // MARK: - Init
    
    init(connectionContext: ConnectionContext) {
        self.connectionContext = connectionContext
    }
    
    // MARK: - Internal Methods

    /// Requests a transaction token from the OAuth server for WebSocket authentication.
    ///
    /// - Parameter type: The authentication type to request a token for.
    ///
    /// - Throws: ``CXoneChatError/missingVisitorId`` if visitor ID is not set.
    /// - Throws: ``CXoneChatError/missingParameter(_:)`` if unable to build the URL.
    /// - Throws: ``CXoneChatError/invalidAccessToken`` if required credentials are missing.
    /// - Throws: ``CXoneChatError/transactionTokenRequestFailed(statusCode:)`` if the request fails with a non-2xx status code.
    /// - Throws: ``CXoneChatError/featureUnavailable(_:)`` if the method is triggered for OAuth explicit authentication type.
    ///
    /// - Returns: A `TransactionTokenDTO` containing the access token and expiration time.
    func requestTransactionToken(for type: AuthenticationTypeDTO) async throws -> TransactionTokenDTO {
        LogManager.trace("Requesting transaction token for \(type)")

        // Explicit PKCE is scope-locked in 4.0 — fail fast before any credential is consulted so a
        // stored refresh token cannot bypass the lock via the refresh-grant path.
        guard type != .oAuthExplicit else {
            throw CXoneChatError.featureUnavailable("Explicit OAuth")
        }

        let url = try buildTokenURL()
        let request = try buildTransactionTokenRequest(url: url, authenticationType: type)

        // Do NOT use fetch(for:) — it logs request/response bodies which contain sensitive tokens.
        // Use data(for:) unconditionally so DEBUG builds don't leak credentials into logs.
        let (data, response) = try await connectionContext.session.data(for: request)

        // Validate HTTP status code
        if let httpResponse = response as? HTTPURLResponse {
            guard (200...299).contains(httpResponse.statusCode) else {
                LogManager.error("Transaction token request failed with HTTP \(httpResponse.statusCode)")
                throw CXoneChatError.transactionTokenRequestFailed(statusCode: httpResponse.statusCode)
            }
        }

        return try JSONDecoder().decode(TransactionTokenDTO.self, from: data)
    }

    /// Exchanges a stored refresh token for a new transaction token and OAuth access token.
    ///
    /// Called automatically by ``requestTransactionToken(for:)`` when the explicit PKCE flow
    /// has a valid refresh token on hand. On failure the error propagates unchanged — there is
    /// no silent fallback.
    ///
    /// - Throws: ``CXoneChatError/missingVisitorId`` if visitor ID is not set.
    /// - Throws: ``CXoneChatError/missingParameter(_:)`` if no refresh token is stored or the URL cannot be built.
    /// - Throws: ``CXoneChatError/transactionTokenRequestFailed(statusCode:)`` on a non-2xx HTTP response.
    ///
    /// - Returns: A fresh `TransactionTokenDTO` with updated WebSocket and OAuth tokens.
    func refreshTransactionToken() async throws -> TransactionTokenDTO {
        LogManager.trace("Refreshing transaction token")

        let url = try buildTokenURL()
        let request = try buildRefreshTokenRequest(url: url)

        // Do NOT use fetch(for:) — it logs request/response bodies which contain sensitive tokens.
        // Use data(for:) unconditionally so DEBUG builds don't leak credentials into logs.
        let (data, response) = try await connectionContext.session.data(for: request)

        // Validate HTTP status code
        if let httpResponse = response as? HTTPURLResponse {
            guard (200...299).contains(httpResponse.statusCode) else {
                throw CXoneChatError.transactionTokenRequestFailed(statusCode: httpResponse.statusCode)
            }
        }

        return try JSONDecoder().decode(TransactionTokenDTO.self, from: data)
    }
}

// MARK: - Private Methods

private extension TransactionTokenService {

    /// Builds the URL for the token endpoint with query parameters.
    ///
    /// - Throws: ``CXoneChatError/missingVisitorId`` if visitor ID is not set.
    /// - Throws: ``CXoneChatError/missingParameter(_:)`` if unable to build the URL.
    func buildTokenURL() throws -> URL {
        guard let visitorId = connectionContext.visitorId else {
            throw CXoneChatError.missingVisitorId
        }

        guard let tokenServerUrl = connectionContext.environment.tokenServerUrl else {
            throw CXoneChatError.missingParameter("tokenServerUrl")
        }

        // Build path: /oauth/token
        guard let urlWithPath = tokenServerUrl / "oauth" / "token" else {
            throw CXoneChatError.missingParameter("urlWithPath")
        }

        // Add query parameters
        let queryParams: [(String, String?)] = [
            ("channelId", connectionContext.channelId),
            ("brandId", connectionContext.brandId.description),
            ("visitorId", visitorId)
        ]

        guard let url = urlWithPath & queryParams else {
            throw CXoneChatError.missingParameter("url")
        }

        return url
    }

    /// Builds the token request with appropriate body structure for the authentication type.
    func buildTransactionTokenRequest(url: URL, authenticationType: AuthenticationTypeDTO) throws -> URLRequest {
        var request = URLRequest(url: url, method: .post, contentType: "application/json")
        let requestBody: [String: Any]

        switch authenticationType {
        case .securedCookie:
            // Secured cookie mode: empty body
            requestBody = [:]

        case .anonymous:
            // Anonymous mode: include type and optional customerIdentity
            var body: [String: Any] = ["type": "anonymous"]

            // Include customerIdentity if available
            if let customer = connectionContext.customer {
                body["customerIdentity"] = [
                    "idOnExternalPlatform": customer.idOnExternalPlatform
                ]
            }

            requestBody = body

        case .oAuthImplicit:
            LogManager.trace("Building implicit OAuth token request (grant_type: implicit)")

            guard let connectionToken = connectionContext.connectionToken?.nilIfEmpty() else {
                throw CXoneChatError.invalidAccessToken
            }

            // Implicit flow: exchange integrator-provided JWT for a transaction token
            let thirdPartyBody: [String: Any] = [
                "grant_type": "implicit",
                "access_token": connectionToken
            ]

            requestBody = ["thirdParty": thirdPartyBody]

        case .oAuthExplicit:
            throw CXoneChatError.featureUnavailable("Explicit OAuth")
        }

        request.httpBody = try JSONSerialization.data(withJSONObject: requestBody)

        return request
    }
    
    /// Builds the token request with appropriate body structure
    func buildRefreshTokenRequest(url: URL) throws -> URLRequest {
        guard let refreshToken = connectionContext.transactionToken?.accessToken?.refreshToken else {
            throw CXoneChatError.missingParameter("refreshToken")
        }
        
        var request = URLRequest(url: url, method: .post, contentType: "application/json")
        let requestBody = [
            "thirdParty": [
                "grant_type": "refresh_token",
                "refresh_token": refreshToken
            ]
        ]
        
        request.httpBody = try JSONSerialization.data(withJSONObject: requestBody)

        return request
    }
}
