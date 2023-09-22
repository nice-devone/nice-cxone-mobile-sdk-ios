import CXoneChatSDK
import PKCE

class LoginWithAmazonUseCase {
    
    func callAsFunction() async throws {
        guard let authenticator = OAuthenticatorsManager.authenticator else {
            throw CommonError.failed("Unable to get OAuth authenticator.")
        }

        let verifier = try generateCodeVerifier()
        let challenge = try generateCodeChallenge(for: verifier)

        CXoneChat.shared.customer.setCodeVerifier(verifier)

        let (_, result) = try await authenticator.authorize(withChallenge: challenge)
        
        if let result {
            CXoneChat.shared.customer.setAuthorizationCode(result.challengeResult)
        } else {
            throw CommonError.unableToParse("result")
        }
    }
}

// MARK: - Preview Mock

class PreviewLoginWithAmazonUseCase: LoginWithAmazonUseCase {
    
    override func callAsFunction() async throws {
        await Task.sleep(seconds: 2)
    }
}
