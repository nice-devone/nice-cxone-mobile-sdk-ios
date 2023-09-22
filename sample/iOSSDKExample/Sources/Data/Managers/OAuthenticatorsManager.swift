import Foundation

enum OAuthenticatorsManager {

    // MARK: - Properties

    static private(set) var authenticators = [OAuthenticator]()

    static var authenticator: OAuthenticator? {
        authenticators.first
    }

    // MARK: - Methods

    static func register(authenticator: OAuthenticator) {
        authenticators.append(authenticator)
    }
}
