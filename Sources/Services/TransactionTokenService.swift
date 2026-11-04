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

    /// HTTP status the token endpoint returns when it rejects the credential presented for a grant.
    ///
    /// One value for every grant type the SDK sends — `implicit`, `authorization_code` and
    /// `refresh_token` all answer a refused credential with 400. A 401 is deliberately *not* treated as a
    /// rejection: the endpoint does not return one, so a 401 reaching the SDK came from a gateway or proxy
    /// in front of it and means the request never reached the token service at all. Reading that as
    /// "your credential is bad" would send an integrator to re-authenticate over an infrastructure fault.
    ///
    /// The status alone is not sufficient, though — see ``credentialRejectedErrorCode``.
    ///
    /// Matches the Android SDK, which moved its own token-rejection check to 400 for the same reason and
    /// likewise excludes 401 deliberately. Changing this value without the Android counterpart would make
    /// an integrator shipping both platforms see the token-delegate listener fire on one and not the other.
    /// The platforms agree on the status but not yet on the cause — Android classifies on 400 alone, so it
    /// still treats every cause below as a dead credential.
    private static let rejectionStatusCode = 400

    /// The one ``TokenErrorResponseDTO/errorCode`` at ``rejectionStatusCode`` that means the credential
    /// itself is dead and the session cannot be recovered without re-authenticating.
    ///
    /// The endpoint answers several unrelated causes with the same 400, and the correct handling for the
    /// others is the opposite: `third_party_request_rejected` is a brand OAuth-configuration fault where
    /// re-authenticating cannot help, and `third_party_unavailable` is a provider that is briefly
    /// unreachable and should be retried. Classifying on the status alone would force a full re-login for
    /// a transient blip or a misconfiguration, so the cause is checked too.
    private static let credentialRejectedErrorCode = "third_party_token_rejected"

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
    /// - Throws: ``CXoneChatError/invalidAccessToken`` if no access token is available for `.oAuthImplicit` —
    ///   neither an integrator-provided JWT nor, on an explicit-PKCE reconnect, a stored explicit access token.
    /// - Throws: ``CXoneChatError/missingParameter(_:)`` if the stored `authorizationCode` or `codeVerifier`
    ///   is missing for the explicit flow's first exchange.
    /// - Throws: `TokenRejectionError` if the endpoint refused the presented credential — a 400 whose
    ///   `errorCode` identifies a rejected credential specifically. Callers decide what a refusal means for
    ///   their flow and map it to a ``CXoneChatError`` before it reaches an integrator.
    /// - Throws: ``CXoneChatError/transactionTokenRequestFailed(statusCode:)`` on any other non-2xx response,
    ///   including a 400 raised by a misconfiguration, an unreachable provider or an unrecognised cause.
    ///
    /// - Returns: A `TransactionTokenDTO` containing the access token and expiration time.
    func requestTransactionToken(for type: AuthenticationTypeDTO) async throws -> TransactionTokenDTO {
        LogManager.trace("Requesting transaction token for \(type)")

        let url = try buildTokenURL()
        let request = try buildTransactionTokenRequest(url: url, authenticationType: type)

        // Do NOT use fetch(for:) — it logs request/response bodies which contain sensitive tokens.
        // Use data(for:) unconditionally so DEBUG builds don't leak credentials into logs.
        let (data, response) = try await connectionContext.session.data(for: request)

        // Validate HTTP status code
        if let httpResponse = response as? HTTPURLResponse {
            guard httpResponse.isSuccess else {
                LogManager.error("Transaction token request failed with HTTP \(httpResponse.statusCode)")

                throw failureError(for: httpResponse, data: data)
            }
        }

        return try JSONDecoder().decode(TransactionTokenDTO.self, from: data)
    }

    /// Exchanges a stored refresh token for a fresh OAuth access token — the first hop of the
    /// explicit-PKCE token-expiry model's case 3 (transaction and access token both expired, refresh
    /// token still valid).
    ///
    /// The response carries no transaction token, only the refreshed access token — minting a new
    /// transaction token from it requires a second, separate call through the implicit-grant endpoint
    /// (see ``ConnectionService``). A rejected grant surfaces as ``CXoneChatError/invalidRefreshToken(_:)``;
    /// every other failure propagates unchanged — there is no silent fallback. "Rejected" means the refresh
    /// token itself is dead, not merely that the grant did not succeed: a provider that is briefly
    /// unreachable, or a brand whose OAuth configuration is wrong, both answer with the same status and stay
    /// retryable rather than forcing the customer through a full re-login.
    ///
    /// - Throws: ``CXoneChatError/missingVisitorId`` if visitor ID is not set.
    /// - Throws: ``CXoneChatError/missingParameter(_:)`` if no refresh token is stored, the URL cannot be
    ///   built, or the response did not include a new access token.
    /// - Throws: ``CXoneChatError/invalidRefreshToken(_:)`` if the backend rejected the refresh token itself,
    ///   carrying the backend's own description of the rejection when it supplied one.
    /// - Throws: ``CXoneChatError/transactionTokenRequestFailed(statusCode:)`` on any other non-2xx response,
    ///   including a grant that failed for a reason the refresh token cannot be blamed for.
    ///
    /// - Returns: The refreshed `AccessTokenDTO`.
    func requestAccessTokenRefresh() async throws -> AccessTokenDTO {
        LogManager.trace("Refreshing OAuth access token via refresh_token grant")

        let url = try buildTokenURL()
        let request = try buildRefreshTokenRequest(url: url)

        // Do NOT use fetch(for:) — it logs request/response bodies which contain sensitive tokens.
        // Use data(for:) unconditionally so DEBUG builds don't leak credentials into logs.
        let (data, response) = try await connectionContext.session.data(for: request)

        // Validate HTTP status code
        if let httpResponse = response as? HTTPURLResponse {
            guard httpResponse.isSuccess else {
                // Mapped here rather than by the caller because a refused *refresh* token is the one
                // rejection whose meaning is unambiguous — the session cannot be recovered — and this is
                // still where the response body, and so the backend's description of it, is in scope.
                let failure = failureError(for: httpResponse, data: data)

                guard let rejection = failure as? TokenRejectionError else {
                    throw failure
                }

                LogManager.warning("Refresh grant rejected — \(rejection.logDescription)")

                throw CXoneChatError.invalidRefreshToken(rejection.message)
            }
        }

        guard let accessToken = try JSONDecoder().decode(RefreshGrantResponseDTO.self, from: data).accessToken else {
            throw CXoneChatError.missingParameter("accessToken")
        }

        return accessToken
    }
}

// MARK: - Private Methods

private extension TransactionTokenService {

    /// The single place a `/oauth/token` status becomes a meaning.
    ///
    /// Returns `TokenRejectionError` only when the endpoint refused the credential the SDK presented —
    /// decoding the backend's description out of the body while it is still in scope — and
    /// ``CXoneChatError/transactionTokenRequestFailed(statusCode:)`` for everything else, which the SDK
    /// cannot interpret and passes through as the raw failure.
    ///
    /// A refusal must match both ``rejectionStatusCode`` and ``credentialRejectedErrorCode``. A 400 whose
    /// cause is absent or unrecognised is deliberately *not* a refusal: an unconfirmable failure is
    /// retryable, and reporting it as a dead credential would force a re-login the SDK cannot justify.
    ///
    /// Callers must not re-test the status afterwards. Keeping that decision here is what stops two flows
    /// hitting the same endpoint from disagreeing about which response means "rejected".
    func failureError(for httpResponse: HTTPURLResponse, data: Data) -> Error {
        // Decoded before the status is examined, so that a cause is logged for every status carrying one and
        // not just for the rejection status: a 403 names a blocked IP or a captcha, and a 404 an unknown
        // brand/channel configuration. None of those survives into `transactionTokenRequestFailed`, so
        // without this they would leave nothing behind but a bare status code to debug from.
        let rejection = try? JSONDecoder().decode(TokenErrorResponseDTO.self, from: data)

        guard httpResponse.statusCode == Self.rejectionStatusCode,
              rejection?.errorCode == Self.credentialRejectedErrorCode else {
            // Gated on a cause having actually been decoded: `try?` succeeds on any JSON object, so a proxy's
            // error page or a 422's validation body yields an all-nil value and would otherwise log a cause
            // for a status that never carried one. "failed" rather than "refused" because this branch is also
            // reached by genuine failures — a 5xx is the endpoint being unreachable and a 422 a request the
            // SDK built wrong, and reading either as a refusal sends an integrator to their OAuth config.
            if let errorCode = rejection?.errorCode {
                LogManager.warning(
                    "Token endpoint failed with HTTP \(httpResponse.statusCode), cause "
                        + "\(errorCode): \(rejection?.message ?? "no description")"
                )
            }

            return CXoneChatError.transactionTokenRequestFailed(statusCode: httpResponse.statusCode)
        }

        return TokenRejectionError(statusCode: httpResponse.statusCode, message: rejection?.message)
    }

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

            // Integrator-provided JWT (implicit flow), or — on an explicit-PKCE reconnect (case 2/3 of the
            // token-expiry model, DE-172253) — the access token from the last stored explicit exchange.
            // Both end up calling this same endpoint the same way; only the token's origin differs.
            guard let accessToken = connectionContext.effectiveAccessToken else {
                throw CXoneChatError.invalidAccessToken
            }

            let thirdPartyBody: [String: Any] = [
                "grant_type": "implicit",
                "access_token": accessToken
            ]

            requestBody = ["thirdParty": thirdPartyBody]

        case .oAuthExplicit:
            LogManager.trace("Building explicit OAuth token request (grant_type: authorization_code)")

            guard let authorizationCode = connectionContext.authorizationCode.nilIfEmpty() else {
                throw CXoneChatError.missingParameter("authorizationCode")
            }
            guard let codeVerifier = connectionContext.codeVerifier.nilIfEmpty() else {
                throw CXoneChatError.missingParameter("codeVerifier")
            }

            // Third-party OAuth: authorization code flow with PKCE code verifier (no client_secret).
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
