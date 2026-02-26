# Case Study: OAuth

This case study will guide you through implementing OAuth 2.0 authentication in a mobile application using the CXone Mobile SDK. We will cover the steps needed to configure OAuth, authenticate the user, and navigate to the chat view once authentication is complete. While this guide uses "Login with Amazon" for illustration, the steps should be adapted to your preferred OAuth provider if required endpoints are available.

## Configure CXone Mobile SDK for OAuth 2.0

The CXone Mobile SDK supports OAuth 2.0, allowing your app to access OAuth-protected APIs using a bearer token. In this example, we'll demonstrate how to configure the chat channel for OAuth and integrate a Login with Amazon OAuth flow in the app.

> Important: The OAuth setup must occur before calling the `connection.connect()` method in your application.

### Step 1: Configure the Chat Channel for OAuth

Before your app can use OAuth, you'll need to configure the chat channel in the CXone system to support OAuth authentication. This step typically involves setting up the OAuth provider and client details within the CXone configuration panel, ensuring the app can securely authenticate the user.

### Step 2: Check if OAuth is Required

When initializing your chat configuration, check if the channel requires OAuth authentication:

```swift
// First, prepare the connection
try await CXoneChat.shared.connection.prepare(
    environment: environment, 
    brandId: brandId, 
    channelId: channelId
)

// Then check if authorization is enabled for this channel
let channelConfig = try await getChannelConfiguration()
let isOAuthEnabled = channelConfig.isAuthorizationEnabled

if isOAuthEnabled {
    // Proceed with OAuth flow
} else {
    // Continue with regular authentication
}
```

### Step 3: Configure Your Application to Prompt the User to Sign In

To begin the OAuth process, prompt the user to sign in with their chosen OAuth service provider. In this example, we'll use Login with Amazon, but the steps would be similar for other OAuth providers like Google, Facebook, or your own identity provider.

The following code snippet initializes an OAuth request:

```swift
let request = AMZNAuthorizeRequest()
request.scopes = [AMZNProfileScope.userID(), AMZNProfileScope.profile()]
request.codeChallengeMethod = "S256"  // Use secure code challenge method
request.grantType = .code  // Specify that we are using an authorization code grant type
```

• Scopes: Define the permissions your application needs. Here, we request the user ID and profile information.
• Code Challenge Method: Indicates that the app will use PKCE (Proof Key for Code Exchange) for enhanced security during the OAuth flow.
• Grant Type: We are using the authorization code flow, which is the most secure and recommended method for server-side applications.

### Step 4: Handle Code Verifier and Code Challenge

If your OAuth provider requires additional security measures like PKCE (which is often the case), your app must generate a code verifier and code challenge. The code verifier is a random string, and the code challenge is a hashed version of that string.

Here's how to generate these values and pass the code verifier to the CXone SDK:

```swift
// Using a PKCE library to generate code verifier
let verifier = try generateCodeVerifier()
let challenge = try generateCodeChallenge(for: verifier)

// Set the code verifier in the SDK
CXoneChat.shared.customer.setCodeVerifier(verifier)

// Set the challenge in your OAuth request
request.codeChallenge = challenge
```

• Code Verifier: A high-entropy, cryptographically random string.
• Code Challenge: A hashed value of the code verifier, typically using SHA-256.

This step strengthens security by ensuring that only the same app that requested the authorization code can exchange it for an access token.

### Step 5: Receive the Authorization Code

After the user successfully signs in with their OAuth provider, the app will receive an authorization code. Pass this code to the CXone SDK:

```swift
try await authenticator.authorize(withChallenge: challenge) { cancelled, result in
    if !cancelled, let result = result {
        // Pass the received authorization code to the CXone SDK
        CXoneChat.shared.customer.setAuthorizationCode(result.challengeResult)
        
        // Now you can connect to CXone
        try await CXoneChat.shared.connection.connect()
    } else {
        // Handle cancellation or error
    }
}
```

• Authorization Code: The code received from the OAuth provider after successful authentication.
• Error Handling: Always handle cases where the authorization might fail, for example, due to network issues or user cancellation.

### Step 6: App Delegate Integration for OAuth URL Handling

Some OAuth providers require handling callback URLs. Add the following to your `AppDelegate`:

```swift
func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey: Any] = [:]) -> Bool {
    if let authenticator = OAuthenticatorsManager.authenticator {
        return authenticator.handleOpen(
            url: url, 
            sourceApplication: options[UIApplication.OpenURLOptionsKey.sourceApplication] as? String
        )
    }
    return false
}
```

### Step 7: Connect to CXone After Authentication

Once the authorization code has been set, you can connect to CXone:

```swift
try await CXoneChat.shared.connection.connect()
```

After successful connection, the SDK will automatically exchange the authorization code for an access token and manage the token lifecycle.

> Warning: It is necessary to have the authorization ALWAYS freshly generated. It can't be reused for new secured sessions flow. 
> The CXoneChatSDK now contains `CXoneChatError.transactionTokenExpired` error that requires to re-trigger OAuth flow to obtain new authorization code and
> code verifier.

> Warning: For every new secured session, you must generate a fresh authorization code and PKCE code verifier.
> Previously issued codes and verifiers cannot be reused. If the SDK throws `CXoneChatError.transactionTokenExpired`,
> handle it by restarting the OAuth flow to obtain a new authorization code and code verifier.

## Complete Code Example

Below is a simplified example of how to implement the OAuth flow in your app:

```swift
class LoginWithAmazonUseCase {
    
    func callAsFunction() async throws {
        guard let authenticator = OAuthenticatorsManager.authenticator else {
            throw CommonError.failed("Unable to get OAuth authenticator.")
        }

        // Generate PKCE code verifier and challenge
        let verifier = try generateCodeVerifier()
        let challenge = try generateCodeChallenge(for: verifier)

        // Pass code verifier to SDK
        CXoneChat.shared.customer.setCodeVerifier(verifier)

        // Perform authorization
        let (_, result) = try await authenticator.authorize(withChallenge: challenge)
        
        if let result {
            // Pass authorization code to SDK
            CXoneChat.shared.customer.setAuthorizationCode(result.challengeResult)
        } else {
            throw CommonError.unableToParse("result")
        }
    }
}
```

## Security Considerations

1. **Use PKCE**: Always implement PKCE to enhance the security of your OAuth flow.
2. **Secure Storage**: The SDK automatically secures OAuth tokens in the device's keychain.
3. **Token Lifecycle**: The SDK handles token renewal automatically; you don't need to manage token expiration.
4. **App Configuration**: Ensure your app is properly registered with your OAuth provider and has the correct redirect URIs configured.

## Troubleshooting

- **Missing Authorization Code**: If `CXoneChat.shared.customer.setAuthorizationCode()` is not called before connecting, you may receive an error.
- **Missing Code Verifier**: If your OAuth provider requires PKCE and you don't set a code verifier, authentication will fail.
- **Invalid Redirect URI**: Ensure your app's URL scheme is correctly configured in your Info.plist and matches what's registered with your OAuth provider.

