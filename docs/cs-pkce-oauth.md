# Case Study: Explicit OAuth (PKCE)

This case study walks through the **explicit OAuth flow** (Authorization Code + PKCE) for the
CXone Mobile SDK. Unlike the [implicit flow](cs-oauth.md), your app never sees a long-lived
access token directly from the OAuth provider — it hands the SDK a one-time authorization code
and PKCE code verifier, and the SDK exchanges those with the CXone backend itself.

> **Tested provider:** as with the implicit flow, the SDK is provider-agnostic at the token
> level. **Google is the currently exercised provider end-to-end** (sample app + CXone backend).

## When to use this flow

The explicit flow fits when you want the **SDK**, not your app, to hold and manage the OAuth
session — your app only ever handles a short-lived authorization code, never a bearer access
token. This is the flow to reach for when you don't want your app to be responsible for token
storage, refresh-token lifecycle, or token security: the CXone backend exchanges the code for
tokens on the first connect, and the SDK — not the backend — persists and manages them from
then on (see *Security considerations* below).

Responsibilities are split like this:

| Your app                                                          | The SDK                                                                |
| ------------------------------------------------------------------ | ----------------------------------------------------------------------- |
| Run the authorization step only — obtain an `authorization_code` and the PKCE `code_verifier` | Exchange the code + verifier for a transaction token via the CXone backend |
| Hand both values to the SDK before `connect()`                     | Store the resulting access/refresh tokens and use them for reconnects |
| Re-run authorization (a fresh code + verifier) when the SDK reports the session cannot be recovered | Detect an expired/rejected token on reconnect or send, and recover automatically where possible |

Compare this to the implicit flow, where your app holds the access token and refresh
responsibility directly via `setConnectionToken(_:expiresAt:)` and a token delegate listener.
With the explicit flow there is no token delegate — recovery is entirely internal to the SDK
until it is no longer possible (see *The token-expiry model* below).

## Prerequisites

The chat channel must be configured in the CXone admin console for OAuth with the explicit
(Authorization Code + PKCE) grant enabled — refer to the platform OAuth integration guide for
the operator-facing setup. Keep "Allow anonymous connection for Mobile SDK" enabled on the
channel; the Mobile SDK requires it regardless of OAuth configuration.

Your app is responsible for the authorization step only:

- Generate a PKCE `code_verifier` (and its `code_challenge` derivation) locally, as required by
  [RFC 7636](https://www.rfc-editor.org/rfc/rfc7636).
- Run the provider's authorization request with that challenge.
- Capture the resulting `authorization_code` and the same `code_verifier` you generated.

The sample app at `sample/iOSSDKExample` uses [AppAuth for iOS][appauth] for this step —
see `GoogleAuthenticator.presentForExplicit()`. AppAuth generates the PKCE parameters
internally and, for the explicit flow, only runs the authorization step in-app; the token
exchange itself is left to the backend.

[appauth]: https://github.com/openid/AppAuth-iOS

## Step 1: Obtain an authorization code and code verifier

Run your provider's authorization request and capture both values from the response — never
the access token:

```swift
func presentForExplicit() async throws -> OAResult {
    try await withCheckedThrowingContinuation { continuation in
        Task { @MainActor in
            guard let presenter = Self.topViewController() else {
                continuation.resume(throwing: CommonError.failed("No presenting view controller available."))
                return
            }

            self.currentSession = OIDAuthorizationService.present(self.makeAuthorizationRequest(), presenting: presenter) { response, error in
                self.currentSession = nil

                guard let response else {
                    continuation.resume(throwing: Self.mapError(error))
                    return
                }
                guard let authorizationCode = response.authorizationCode else {
                    continuation.resume(throwing: OAError.missingValue("authorizationCode"))
                    return
                }
                guard let codeVerifier = response.request.codeVerifier else {
                    continuation.resume(throwing: OAError.missingValue("codeVerifier"))
                    return
                }

                continuation.resume(returning: .explicit(authorizationCode: authorizationCode, codeVerifier: codeVerifier))
            }
        }
    }
}
```

## Step 2: Hand the code and verifier to the SDK

Pass both values to the SDK after `prepare(...)` and before `connect()`. Order does not matter
between the two setter calls, but both must happen before `connect()`:

```swift
try await chatProvider.connection.prepare(
    environment: environment,
    brandId: brandId,
    channelId: channelId
)

chatProvider.customer.setAuthorizationCode(authorizationCode)
chatProvider.customer.setCodeVerifier(codeVerifier)
```

Setting either of these clears any previously-set implicit-flow `connectionToken`, so a channel
resolves deterministically to the explicit flow once you call these — see
`ConnectionContext.authenticationType`. Don't call `setConnectionToken(_:expiresAt:)` for the
same session; the two flows are mutually exclusive per connection attempt.

## Step 3: Connect

```swift
try await chatProvider.connection.connect()
```

On the first sign-in, `connect()` exchanges the authorization code and verifier for a
transaction token via the CXone backend's `/oauth/token` endpoint
(`grant_type=authorization_code`, no `client_secret`). This exchange is **single-use** — the
authorization code cannot be replayed. Everything after this first exchange (reconnects,
expiry, refresh) is handled internally by the token-expiry model below, without your app
supplying a code or verifier again.

If the exchange fails because the backend rejects the code/verifier itself (misconfigured
channel, wrong redirect URI, or a code that was already consumed or expired), `connect()`
throws `CXoneChatError.transactionTokenRequestFailed(statusCode:)`. There is no automatic
recovery for a rejected first exchange — re-run Step 1 to get a fresh code and verifier.

A transient backend failure (`statusCode` in the 5xx range, e.g. a provider outage) also
surfaces as `transactionTokenRequestFailed(statusCode:)`. The SDK keeps the code and
verifier and returns to `.prepared`, so you can retry `connect()` once without calling the
setters again. The code may already have been spent or expired, though, so if the retry
fails, re-run Step 1.

## The token-expiry model

Once the first exchange succeeds, the SDK tracks three credentials internally: the transaction
token (used to authenticate the WebSocket), the OAuth access token backing it, and — if the
backend issued one — a refresh token. Every subsequent **reconnect** (e.g. `connect()` called
again after the socket dropped) falls into one of four cases, based on which of those are still
valid:

| Case | State                                                              | What the SDK does                                                                 |
| ---- | -------------------------------------------------------------------- | ------------------------------------------------------------------------------------ |
| 1    | Transaction token still valid                                        | No-op — the cached token is reused.                                                  |
| 2    | Transaction token expired, access token still valid                  | Mints a new transaction token via the implicit-grant endpoint, reusing the stored access token. Never replays the authorization code. |
| 3    | Transaction *and* access token expired, refresh token valid          | Spends the refresh token (`grant_type=refresh_token`) for a new access token, then repeats case 2's implicit-grant call with it. |
| 4    | Refresh token also invalid, missing, or the refresh grant returns no new access token | No refresh path exists. The SDK throws `CXoneChatError.invalidRefreshToken(_:)` — your app must re-run Step 1 with a fresh authorization code and verifier. |

An outbound **message send** doesn't walk this table — it only ever cares about the OAuth
access token, not the transaction token. Before sending, the SDK checks the access token's
expiry and, if it's expiring, refreshes it the same way case 3 does (spending the refresh token
if needed). So a conversation left idle past the access token's lifetime still sends normally
instead of failing outright, mirroring `ChatThreadProvider.send(_:)`'s existing error surface —
it just gets there via this access-token refresh, not via the reconnect table above.

A rejection on cases 2 or 3 is only treated as "the credential is dead" when the backend's
response explicitly says so. A transient failure — the provider being briefly unreachable, or a
misconfigured channel — surfaces as `CXoneChatError.transactionTokenRequestFailed(statusCode:)`
instead, and is safe to retry without forcing a re-login.

### Case 4: handling `invalidRefreshToken`

```swift
do {
    try await chatProvider.connection.connect()
} catch CXoneChatError.invalidRefreshToken(let message) {
    // The session cannot be recovered automatically. Re-run Step 1 (a fresh
    // authorization-code + PKCE grant) and call setAuthorizationCode/setCodeVerifier again.
    logger.warning("Explicit OAuth session expired: \(message ?? "no further detail")")
    presentSignInUI()
}
```

`invalidRefreshToken`'s associated `String?` carries the backend's own description of the
rejection when the backend was the one that rejected the refresh token — useful for logs, but a
fixed string tied to the backend's error code rather than the OAuth provider's own wording, so
don't parse or branch on it. It is `nil` for the two purely local causes: no refresh token was
ever stored, or a refresh grant succeeded without returning a new access token.

Distinguish this from `CXoneChatError.invalidAccessToken`, which signals that a credential
needed refreshing but nothing was available to do it — for the implicit flow, a missing token
delegate listener. An explicit-flow app can still receive it too (for example when no socket
delegate is available to perform a pre-send refresh, or when a reconnect has no usable stored
access token), so handle both regardless of which flow you're on.

## Complete code example

The sample app's `GoogleSignInUseCase` wires the explicit flow end-to-end:

```swift
func callAsFunction(flow: OAuthFlow) async throws {
    guard let authenticator = OAuthenticatorsManager.authenticator else {
        throw CommonError.failed("Unable to get OAuth authenticator.")
    }

    let result = try await authenticator.authorize(flow: flow)

    switch result {
    case .explicit(let authorizationCode, let codeVerifier):
        chatProvider.customer.setAuthorizationCode(authorizationCode)
        chatProvider.customer.setCodeVerifier(codeVerifier)
    case .implicit(let connectionToken, let expiresAt):
        chatProvider.customer.setConnectionToken(connectionToken, expiresAt: expiresAt)
    }
}
```

**The authorization code and verifier are one-shot — the session they establish is not.**
Unlike the implicit flow's `OIDAuthState`, the code and verifier themselves cannot be persisted
and replayed after an app relaunch; they are single-use by design and Step 1 always produces a
fresh pair. But the transaction token the first exchange produced is Keychain-backed and
survives the relaunch, so a returning user with a still-valid cached credential (or a live
refresh token) reconnects through the token-expiry model above without a new authorization
code. The sample app's own `restoreSession()` still gates on the implicit flow only — that's an
app-level policy choice in this sample, not an SDK limitation, so a custom integration is free
to skip re-running Step 1 whenever the SDK's own recovery would succeed.

## Security considerations

1. **Never log the authorization code or verifier.** Both are one-time credentials; treat them
   with the same care as a bearer token even though they're short-lived.
2. **Validate the redirect URI on every flow.** A misconfigured custom URL scheme is one of the
   most common ways to leak an authorization code — confirm the scheme registered with your
   OAuth provider matches `CFBundleURLSchemes` in your `Info.plist` exactly.
3. **The SDK holds tokens after the first exchange, not your app.** Access and refresh tokens
   live inside the SDK's connection context for the rest of the session. Your app never
   receives them directly under this flow.

## Troubleshooting

- **`transactionTokenRequestFailed(statusCode:)` from `connect()` on first sign-in.** The
  backend rejected the authorization code or verifier itself. Two independent causes: a
  misconfigured channel redirect URI, or a code/verifier that was already consumed. The reuse
  cause only happens if your app calls `setAuthorizationCode`/`setCodeVerifier` again with a
  code or verifier it already spent — those setters reset the session to a first-exchange
  state, so a plain second `connect()` after a successful exchange does **not** hit this; it
  goes through the token-expiry model above instead. Confirm the channel's OAuth redirect URI
  configuration, and re-run Step 1 for a fresh code if the code may have already been spent.
- **`invalidRefreshToken` shows up sooner than expected.** Confirm the OAuth provider is actually
  issuing a refresh token on the authorization request (some providers require an explicit
  offline-access scope even for the authorization-code grant). Without one, any access-token
  expiry is unrecoverable and immediately becomes case 4.
- **Migrating from a version where this flow threw `featureUnavailable("Explicit OAuth")`.**
  That gate is removed — the flow is fully implemented. A failed first-exchange now surfaces as
  `CXoneChatError.transactionTokenRequestFailed(statusCode:)` instead; update any code that
  matched on `featureUnavailable` for this case.
