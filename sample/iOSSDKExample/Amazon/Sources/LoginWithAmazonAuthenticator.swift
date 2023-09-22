import Foundation
import LoginWithAmazon

class LoginWithAmazonAuthenticator: OAuthenticator {

    // MARK: - Properties

    private let manager: AMZNAuthorizationManager

    /// authenticator name
    let authenticatorName = "Amazon"

    // MARK: - Init

    static func initialize() {
        let authenticator = LoginWithAmazonAuthenticator(manager: AMZNAuthorizationManager.shared())
        OAuthenticatorsManager.register(authenticator: authenticator)
    }

    init(manager: AMZNAuthorizationManager) {
        self.manager = manager
    }

    // MARK: - Methods

    /// attempt OAuth authentication using this authenticator
    ///
    /// - parameters:
    ///     - withChallenge: Challenge string
    ///     - onCompletion: routine to invoke on completion of request
    func authorize(withChallenge: String) async throws -> OAAuthenticationHandler {
        let request = AMZNAuthorizeRequest()
        request.scopes = [AMZNProfileScope.userID(), AMZNProfileScope.profile()]
        request.codeChallengeMethod = "S256"
        request.grantType = .code
        request.codeChallenge = withChallenge

        return try await withCheckedThrowingContinuation { continuation in
            manager.authorize(request) { result, cancelled, error in
                if let error {
                    continuation.resume(throwing: error)
                } else {
                    continuation.resume(returning: (cancelled, result.map { OAResult(challengeResult: $0.authorizationCode) }))
                }
            }
        }
    }
    
    /// Attempt to clear OAuth login status of this authenticator
    func signOut() async throws {
        try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<Void, Error>) -> Void in
            manager.signOut { error in
                if let error {
                    continuation.resume(throwing: error)
                } else {
                    continuation.resume()
                }
            }
        }
    }

    /// handle an open url request from the application, this may be required to complete
    /// some varieties of OAuth
    ///
    /// - parameters:
    ///     - url: url being opened
    ///     - sourceApplication: name of application originating request
    func handleOpen(url: URL, sourceApplication: String?) -> Bool {
        AMZNAuthorizationManager.handleOpen(url, sourceApplication: sourceApplication)
    }
}
