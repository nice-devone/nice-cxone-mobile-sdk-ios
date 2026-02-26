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

/// Service for transaction token exchange with the backend.
class TransactionTokenService {
    
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
    /// - Throws: ``CXoneChatError/transactionTokenRequestFailed(statusCode:)`` if the request fails with a non-2xx status code.
    ///
    /// - Returns: A `TransactionTokenDTO` containing the access token and expiration time.
    func requestTransactionToken(for type: AuthenticationType) async throws -> TransactionTokenDTO {
        LogManager.trace("Requesting transaction token for \(type)")

        let url = try buildTokenURL()
        let request = try buildTransactionTokenRequest(url: url, authenticationType: type)

        // Do NOT use fetch(for:) - it logs request/response bodies which contain sensitive tokens.
        // Use data(for:) to avoid logging sensitive authentication data.
        #if DEBUG
        let (data, response) = try await connectionContext.session.fetch(for: request)
        #else
        let (data, response) = try await connectionContext.session.data(for: request)
        #endif

        // Validate HTTP status code
        if let httpResponse = response as? HTTPURLResponse {
            guard (200...299).contains(httpResponse.statusCode) else {
                throw CXoneChatError.transactionTokenRequestFailed(statusCode: httpResponse.statusCode)
            }
        }

        return try JSONDecoder().decode(TransactionTokenDTO.self, from: data)
    }
    
    func refreshAccessToken() async throws -> AccessTokenDTO {
        LogManager.trace("Refreshing access token")

        let url = try buildTokenURL()
        let request = try buildRefreshTokenRequest(url: url)

        // Do NOT use fetch(for:) - it logs request/response bodies which contain sensitive tokens.
        // Use data(for:) to avoid logging sensitive authentication data.
        #if DEBUG
        let (data, response) = try await connectionContext.session.fetch(for: request)
        #else
        let (data, response) = try await connectionContext.session.data(for: request)
        #endif

        // Validate HTTP status code
        if let httpResponse = response as? HTTPURLResponse {
            guard (200...299).contains(httpResponse.statusCode) else {
                throw CXoneChatError.transactionTokenRequestFailed(statusCode: httpResponse.statusCode)
            }
        }

        return try JSONDecoder().decode(AccessTokenDTO.self, from: data)
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
    func buildTransactionTokenRequest(url: URL, authenticationType: AuthenticationType) throws -> URLRequest {
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

        case .thirdPartyOAuth:
            guard let authorizationCode = connectionContext.authorizationCode.nilIfEmpty() else {
                throw CXoneChatError.missingParameter("authorizationCode")
            }
            guard let codeVerifier = connectionContext.codeVerifier.nilIfEmpty() else {
                throw CXoneChatError.missingParameter("codeVerifier")
            }
            
            // Third-party OAuth: Authorization code flow with PKCE code verifier
            let thirdPartyBody: [String: Any] = [
                "grant_type": "authorization_code",
                "authorization_code": authorizationCode,
                "code_verifier": codeVerifier
            ]

            requestBody = ["thirdParty": thirdPartyBody]
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
