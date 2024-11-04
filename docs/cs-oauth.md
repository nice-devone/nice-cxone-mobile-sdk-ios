# Case Study: OAuth

This case study will guide you through implementing OAuth 2.0 authentication in a mobile application using the CXone Mobile SDK. We will cover the steps needed to configure OAuth, authenticate the user, and navigate to the chat view once authentication is complete. While this guide uses “Login with Amazon” for illustration, the steps should be adapted to your preferred OAuth provider if required endpoints are available.

## Configure CXone Mobile SDK for OAuth 2.0

The CXone Mobile SDK supports OAuth 2.0, allowing your app to access OAuth-protected APIs using a bearer token. In this example, we’ll demonstrate how to configure the chat channel for OAuth and integrate a Login with Amazon OAuth flow in the app.

> Important: This must occur before calling the  `connect()` method in your application.

### Step 1: Configure the Chat Channel for OAuth

Before your app can use OAuth, you’ll need to configure the chat channel in the CXone system to support OAuth authentication. This step typically involves setting up the OAuth provider and client details within the CXone configuration panel, ensuring the app can securely authenticate the user.

### Step 2: Configure Your Application to Prompt the User to Sign In

To begin the OAuth process, prompt the user to sign in with their chosen OAuth service provider. In this example, we’ll use Login with Amazon, but the steps would be similar for other OAuth providers like Google, Facebook, or your own identity provider.

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

### Step 3: Handle Code Verifier and Code Challenge

If your OAuth provider requires additional security measures like PKCE (which is often the case), your app must generate a code verifier and code challenge. The code verifier is a random string, and the code challenge is a hashed version of that string.

Here’s how to generate these values and pass the code verifier to the CXone SDK:

```swift
let request = AMZNAuthorizeRequest()
...

do {
    // Generate code verifier and challenge
    let codeVerifier = try generateCodeVerifier()
    request.codeChallenge = try generateCodeChallenge(for: codeVerifier)
    
    // Pass code verifier to CXone SDK
    CXOneChat.shared.customer.setCodeVerifier(codeVerifier)
} catch {
    // Handle error (e.g., log or display an error message)
    print("Error generating code verifier or challenge: \(error)")
}
```

• Code Verifier: A high-entropy, cryptographically random string.
• Code Challenge: A hashed value of the code verifier, using SHA-256.

This step strengthens security by ensuring that only the same app that requested the authorization code can exchange it for an access token.

### Step 4: Receive the Authorization Code

After the user successfully signs in with their OAuth provider, the app will receive an authorization code. This code can then be exchanged for an access token, which will be used to authenticate API requests.

Here’s how to handle the sign-in result and pass the authorization code to the CXone SDK:

```swift
let request = AMZNAuthorizeRequest()
...

AMZNAuthorizationManager.shared().authorize(request) { [weak self] result, _, error in
    if let error = error {
        // Handle error (e.g., display an error message)
        print("Authorization error: \(error)")
        return
    }

    // Pass the received authorization code to the CXone SDK
    if let authorizationCode = result?.authorizationCode {
        CXOneChat.shared.customer.setAuthorizationCode(authorizationCode)
    } else {
        // Handle case where authorization code is missing
        print("Authorization code is missing")
    }
}
```

• AMZNAuthorizationManager.shared().authorize: Initiates the authorization flow with the OAuth provider.
• result.authorizationCode: Extracts the authorization code from the result to be passed to the CXone SDK.
• Error Handling: Always handle cases where the authorization might fail, for example, due to network issues or user cancellation.

### Step 5: Navigate to Chat View After Successful Authentication

Once the user has been authenticated and the authorization code has been set in the SDK, the app can proceed to the chat view. It’s important to ensure that all authentication steps are complete before navigating.
