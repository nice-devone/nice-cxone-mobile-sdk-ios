# Case Study: OAuth

This case study walks through integrating OAuth 2.0 authentication in a mobile app that uses
the CXone Mobile SDK. It covers the **implicit flow** (also called *bring-your-own token*),
where your app already obtains an OAuth access token from a third-party provider — Google,
Microsoft Entra, or your own OIDC-compliant identity service — and hands that token to the SDK.

> **Tested provider:** the SDK itself is provider-agnostic — it holds a bearer token string
> and an expiry date, and doesn't care which OAuth provider issued them. **Google is the
> currently exercised provider end-to-end** (both in the sample app and against the CXone
> backend). Other standards-compliant OIDC providers should work with matching channel-side
> configuration, but have not been verified by NICE at time of writing.

> **Migrating from 3.3.x?** The authorization-code + PKCE flow (`setAuthorizationCode`,
> `setCodeVerifier`) is temporarily unavailable in 4.0. The setters themselves do not throw —
> attempting the explicit flow fails with `CXoneChatError.featureUnavailable("Explicit OAuth")`
> from `connect()` during the token exchange. It will re-enable in a future 4.0.x release. Migrate
> to the implicit flow described below.

## When to use this flow

The implicit flow fits when **your app already integrates with an OAuth provider for some
other purpose** — you sign your users in with Google Sign-In, Firebase Auth, Microsoft
Entra, or your own identity service — and you want to reuse that access token to
authenticate the CXone chat session. Your app owns the OAuth handshake and the
refresh-token lifecycle; the SDK just consumes the resulting access token.

**Which providers qualify.** The SDK holds a bearer token string; the CXone backend
validates it by calling the provider's **UserInfo** endpoint (configured on the channel).
A provider qualifies if it issues resource-server access tokens compatible with a standard
OIDC `/userinfo` bearer-token flow. Google, Microsoft Entra, and most self-hosted OIDC
providers meet this bar. Apple's *Sign in with Apple* does **not** map cleanly to this
pattern — its user identity comes back in an `id_token` (JWT), not a resource-server
access token, and it does not expose a standard UserInfo endpoint. Passing an `id_token`
where a bearer access token is expected fails validation at the backend.

Responsibilities are split like this:

| Your app                                                                | The SDK                                                                                    |
| ----------------------------------------------------------------------- | ------------------------------------------------------------------------------------------ |
| Run the OAuth handshake; obtain `access_token` + `refresh_token`        | Embed the access token in outbound chat messages                                           |
| Hand the access token and its expiry to the SDK                         | Track expiry and ask the token delegate for a fresh token shortly before the current one expires |
| Register a token delegate listener the SDK can call to rotate tokens    | Ask the same delegate at connect time if the backend rejects the current token             |
| Re-authenticate the user when silent refresh is no longer possible      | Surface `CXoneChatError.invalidAccessToken` if the listener throws                         |

## Prerequisites

The implicit flow has one easy-to-miss prerequisite at the OAuth-provider layer: **your
authorization request must ask for offline access**, so the provider returns a `refresh_token`
alongside the `access_token`. Without a refresh token your app cannot silently rotate the
access token, and the user will be prompted to sign in again every time the token expires
(typically every hour with Google).

The exact parameter varies by provider:

| Provider              | Parameter                              |
| --------------------- | -------------------------------------- |
| Google                | `access_type=offline`                  |
| Microsoft / Entra ID  | Include `offline_access` in `scope`    |
| Generic OAuth 2.0     | Include `offline_access` in `scope`    |

The sample app at `sample/iOSSDKExample` uses [AppAuth for iOS][appauth] as the OAuth client
library and demonstrates the Google variant — see `GoogleAuthenticator.makeAuthorizationRequest()`.

[appauth]: https://github.com/openid/AppAuth-iOS

## Step 1: Configure the chat channel for OAuth

Before any code change, the chat channel in the CXone admin console must be configured for
OAuth and your OAuth provider's client metadata registered. Refer to the platform OAuth
integration guide for the operator-facing setup. For the implicit flow described here, the
critical field is the **UserInfo** endpoint of your OAuth provider — the backend uses it to
validate the access token your app supplies. Keep "Allow anonymous connection for Mobile
SDK" enabled on the channel; the Mobile SDK requires it regardless of OAuth configuration.

### Google-specific: enable custom UserInfo field mapping

If your OAuth provider is Google, the channel's UserInfo response mapping must be
customized. Google's OIDC `/userinfo` endpoint returns fields named `sub`, `given_name`,
and `family_name`, which do not match the CXone platform's default field names
(`id`, `firstName`, `lastName`). Without a mapping, the backend rejects the token
exchange with an `Invalid data from userInfo endpoint` error and the SDK surfaces it
as `CXoneChatError.invalidAccessToken`.

In the channel's OAuth Settings page, scroll to the **Mapping** section, check
**Enable custom mapping**, and set the following values:

| CXone field         | Google `/userinfo` field |
| ------------------- | ------------------------ |
| Customer id         | `sub`                    |
| Customer first name | `given_name`             |
| Customer last name  | `family_name`            |

Save the channel. This is a per-channel setting — every Google-backed channel needs it
applied once. Providers whose `/userinfo` response already uses `id`, `firstName`, and
`lastName` do not need this step; consult your provider's OIDC UserInfo documentation
if you are unsure.

## Step 2: Check whether OAuth is required

Channel configuration tells you whether the current channel requires OAuth. Read it after
`prepare(...)` and before `connect()`:

```swift
let chatProvider = CXoneChat()

try await chatProvider.connection.prepare(
    environment: environment,
    brandId: brandId,
    channelId: channelId
)

let channelConfig = try await chatProvider.connection.getChannelConfiguration(
    environment: environment,
    brandId: brandId,
    channelId: channelId
)

if channelConfig.isAuthorizationEnabled {
    // Run the OAuth flow described below before connect()
} else {
    // Proceed with the standard (anonymous) connection
    try await chatProvider.connection.connect()
}
```

## Step 3: Wire the OAuth redirect URL into your app's open-URL handler

OAuth providers redirect back to your app via a custom URL scheme after the user signs in.
Whatever component you use to drive the sign-in flow (the sample's `OAuthenticatorsManager`,
AppAuth directly, or your own wrapper) needs the redirect URL forwarded to it from the
app-level open-URL handler.

In a SwiftUI app — which is what the sample uses — attach `.onOpenURL` to a long-lived view
in your `App.body`:

```swift
@main
struct MyApp: App {
    var body: some Scene {
        WindowGroup {
            RootView()
                .onOpenURL { url in
                    // `sourceApplication: nil` — SwiftUI's `onOpenURL` does not expose
                    // `UIApplicationOpenURLOptionsKey.sourceApplication`. The OAuth authenticator
                    // accepts `nil` and its `ASWebAuthenticationSession`-based flow does not require it.
                    _ = OAuthenticatorsManager.authenticator?.handleOpen(url: url, sourceApplication: nil)
                }
        }
    }
}
```

In a UIKit-based app, the equivalent hook is
`UIApplicationDelegate.application(_:open:options:)`:

```swift
func application(
    _ app: UIApplication,
    open url: URL,
    options: [UIApplication.OpenURLOptionsKey: Any] = [:]
) -> Bool {
    if let authenticator = OAuthenticatorsManager.authenticator {
        return authenticator.handleOpen(
            url: url,
            sourceApplication: options[.sourceApplication] as? String
        )
    }
    return false
}
```

If you use AppAuth directly without the sample's `OAuthenticatorsManager` indirection, the
equivalent call is `resumeExternalUserAgentFlow(with: url)` on the `OIDExternalUserAgentSession`
returned by `OIDAuthState.authState(byPresenting:presenting:callback:)`.

## Step 4: Obtain an access token from your OAuth provider

Run your provider's sign-in flow and capture three values:

1. The **access token** itself (a short-lived JWT).
2. The **absolute expiry date** of that access token.
3. A handle that lets you request a fresh access token later — an `OIDAuthState` for AppAuth,
   or whatever your provider library exposes.

The sample's AppAuth-with-Google integration lives in
`sample/iOSSDKExample/Sources/Data/Managers/GoogleAuthenticator.swift`. The relevant
fragment:

```swift
OIDAuthState.authState(byPresenting: makeAuthorizationRequest(), presenting: presenter) { authState, error in
    guard let authState,
          let accessToken = authState.lastTokenResponse?.accessToken,
          let expiresAt = authState.lastTokenResponse?.accessTokenExpirationDate else {
        continuation.resume(throwing: error ?? OAError.missingValue("accessToken"))
        return
    }

    // Retain `authState` — Step 6's refresh listener needs it.
    self.authState = authState

    continuation.resume(returning: .implicit(connectionToken: accessToken, expiresAt: expiresAt))
}
```

Retain the auth-state object somewhere outside the sign-in callback's local scope — Step 6
needs it. The sample keeps it on `GoogleAuthenticator` itself (declared `@unchecked Sendable`,
holding the `OIDAuthState` privately) and exposes a `refreshImplicitToken()` method the token
delegate listener calls, so the rest of the app never touches `OIDAuthState` (an `NSObject`)
directly.

## Step 5: Hand the access token + expiry to the SDK

Before calling `connect()`, give the SDK both the access token and its expiry date:

```swift
chatProvider.customer.setConnectionToken(accessToken, expiresAt: expiresAt)
```

The expiry argument drives proactive refresh. The SDK guards every outbound message: if the
current access token is within roughly ten seconds of `expiresAt` when you send, the SDK
pauses the send, asks the token delegate listener (Step 6) for a fresh token, applies it,
then resumes the send — all without surfacing an error. Passing a fabricated far-future
expiry disables the proactive path; the SDK then only asks for a fresh token *after* the
backend rejects the current one at connect time (see Step 7). Always pass the real
`expires_in` value from your OAuth provider.

## Step 6: Register the token delegate listener

The listener is a `@Sendable` async closure the SDK invokes when it needs a fresh token. It
receives a `TokenRequestReason` — describing *why* the SDK is asking — and returns an
`OAuthToken` containing the freshly issued credential and its expiry:

```swift
public typealias TokenDelegateListener =
    @Sendable (TokenRequestReason) async throws -> OAuthToken

public enum TokenRequestReason: Sendable, Equatable {
    case tokenExpired   // proactive: current token is about to expire
    case tokenInvalid   // reactive: backend rejected the token at connect (HTTP 401)
}
```

Register the listener by passing it to **`setTokenDelegateListener(_:)`** immediately
after `setConnectionToken(_:expiresAt:)`:

```swift
chatProvider.customer.setTokenDelegateListener { reason in   // ← this call registers the listener
    let refreshed = try await authenticator.refreshImplicitToken()

    return OAuthToken(accessToken: refreshed.token, expiresAt: refreshed.expiresAt)
}
```

The same listener handles **both** the proactive and the reactive path. Concurrent
operations that all need a fresh token queue behind a single refresh, so your listener runs
at most once at a time even under load.

Two rules the listener must follow:

1. **Return a *fresh* token and its real expiry.** Returning the same expired token will
   trigger another refresh request on the very next send.
2. **Throw on unrecoverable failure** — revoked refresh token, network down, user no longer
   signed in. The SDK does not retry your closure; it propagates the failure as described in
   Step 7.

Remove the listener on sign-out to clear any retained references:

```swift
chatProvider.customer.setTokenDelegateListener(nil)
```

## Step 7: Handle refresh failure

If your listener throws — or you never registered one and the current token becomes unusable
— the pending SDK operation fails with `CXoneChatError.invalidAccessToken`. This can surface
from `connect()` (at connect time) or from any outbound method that depended on a valid
token (e.g. sending a message). Semantically: *the SDK has given up on the current token and
will not auto-recover; your app needs to intervene.* The cue is to re-present sign-in UI.

Catch the error at the call site, or observe it through the events stream — whichever fits
your architecture:

```swift
do {
    try await chatProvider.connection.connect()
} catch CXoneChatError.invalidAccessToken {
    // Stop accepting user input, re-present the OAuth sign-in flow,
    // and call setConnectionToken(_:expiresAt:) again with the new token.
}
```

Registering a token delegate listener is not strictly required by the API, but skipping it
means every expired-token event immediately becomes a re-auth prompt. In practice, the
listener is what makes the implicit flow feel silent to the user.

## Step 8: Connect

Once the token, expiry, and listener are wired up:

```swift
try await chatProvider.connection.connect()
```

After this, the SDK manages access-token bookkeeping for outbound traffic. Outbound chat
messages embed the current access token in their `data.accessToken.token` field — see
`SendMessageEventDataDTO` and `SendOutboundMessageEventDataDTO` for the exact wire shape.
The proactive guard rotates the token before each send if it is within roughly ten seconds
of expiry; a refresh initiated by one send blocks any concurrent sends until the new token
is in place.

## Complete code example

The sample app at `sample/iOSSDKExample/` is the reference implementation. The three files
that together demonstrate the full flow:

- `Sources/Data/Managers/GoogleAuthenticator.swift` — AppAuth integration; runs the sign-in
  presentation, retains the `OIDAuthState` internally, and exposes
  `refreshImplicitToken() async throws -> (token: String, expiresAt: Date)` for the SDK listener.
- `Sources/Domain/UseCases/GoogleSignInUseCase.swift` — wires `setConnectionToken` +
  `setTokenDelegateListener` together, calling `authenticator.refreshImplicitToken()` inside
  the listener. Start here when adapting the pattern to a different OAuth provider.

A complete example:

```swift
@MainActor
final class OAuthSignInUseCase {

    private let chatProvider: ChatProvider
    private let authenticator: OAuthenticator

    init(chatProvider: ChatProvider, authenticator: OAuthenticator) {
        self.chatProvider = chatProvider
        self.authenticator = authenticator
    }

    func signInAndConnect() async throws {
        let result = try await authenticator.authorize(flow: .implicit)

        guard case let .implicit(connectionToken, expiresAt) = result else {
            throw OAError.missingValue("implicit result")
        }

        chatProvider.customer.setConnectionToken(connectionToken, expiresAt: expiresAt)
        chatProvider.customer.setTokenDelegateListener { reason in
            let refreshed = try await authenticator.refreshImplicitToken()

            return OAuthToken(accessToken: refreshed.token, expiresAt: refreshed.expiresAt)
        }

        try await chatProvider.connection.connect()
    }
}
```

## Security considerations

1. **Request offline access.** Without a `refresh_token` from your provider, the SDK's
   token delegate listener has no way to mint a new access token silently — every expiry
   will force the user to re-authenticate. See *Prerequisites* above for provider-specific
   parameters.
2. **Treat the access token as sensitive.** Don't log it, don't persist it in plaintext. If
   you persist your provider's auth state across app launches, store it in the Keychain.
   AppAuth ships `NSKeyedArchiver`-compatible serialization for `OIDAuthState`, but writing
   the resulting `Data` into the Keychain (and reading it back) is your responsibility —
   the sample app does exactly this (`AuthStateStore` in `GoogleAuthenticator`) so a
   returning user's session can be restored and silently refreshed after a relaunch.
3. **Validate the redirect URI on every flow.** A misconfigured custom URL scheme is one of
   the most common ways to leak an authorization code. Confirm the scheme registered with
   your OAuth provider matches `CFBundleURLSchemes` in your `Info.plist` exactly.
4. **The listener is `@Sendable`.** Don't capture or mutate state from inside the closure
   without proper synchronization. The sample keeps the `OIDAuthState` behind
   `GoogleAuthenticator` (`@unchecked Sendable`) and exposes only `refreshImplicitToken()`,
   so the closure captures a `Sendable` reference rather than the `NSObject` directly.

## Troubleshooting

- **The user is prompted to sign in every hour.** Almost always means your authorization
  request didn't include offline access, so your provider library has no `refresh_token` to
  use — the listener asks for a new token and the provider refuses, and the SDK surfaces
  `CXoneChatError.invalidAccessToken`. Confirm `access_type=offline` (Google) or
  `offline_access` in `scope` (OIDC) is present in the request.
- **`invalidAccessToken` after the user has been signed in for days or weeks.** Expected.
  Refresh tokens have finite lifetimes (Google: until revoked, or six months of inactivity;
  other providers vary). Treat this error as the canonical "re-auth the user" signal.
- **The listener is never called.** Verify (a) you passed a real `expiresAt` to
  `setConnectionToken(_:expiresAt:)` rather than a far-future date, and (b) you registered
  the listener *before* the first send. The SDK only consults the listener within the
  pre-expiry guard window (roughly ten seconds); a far-future expiry deliberately bypasses
  it and only leaves the reactive path.
- **`connect()` fails with `CXoneChatError.invalidAccessToken`.** Either you never called
  `setConnectionToken(_:expiresAt:)`, or the token you passed was already expired and no
  listener was registered to refresh it. Both checks must happen *before* `connect()`.
- **Send fails with `CXoneChatError.invalidAccessToken` mid-session.** Your listener threw
  and the guard couldn't recover. Catch the error at your send site, surface a "session
  expired" UI state, and drive the re-auth flow from there.
- **`featureUnavailable("Explicit OAuth")` thrown from `connect()` after setting an authorization code.**
  The explicit (PKCE) flow is disabled in 4.0 — `setAuthorizationCode(_:)` / `setCodeVerifier(_:)`
  store their values without throwing, and the error surfaces when the token exchange attempts
  the explicit path. It will re-enable in a future 4.0.x release once the backend dependency
  lands. Use the implicit flow described in this document.
- **Reading `OIDAuthState` off the main thread.** AppAuth invokes the
  `performAction(freshTokens:)` callback on the main thread, but `OIDAuthState` is a
  reference-typed `NSObject` and is not documented as thread-safe. If you wrap AppAuth
  yourself, keep all reads of `authState.lastTokenResponse` (and its properties) on the
  main thread. The sample's `GoogleAuthenticator.refreshImplicitToken()` enforces this defensively
  by wrapping the callback body in `Task { @MainActor in ... }`.
