import Foundation

/// an object capable of performing OAuth authentication
protocol OAuthenticator {

    // MARK: - Type Aliases

    /// Invoked when an authentication request completes
    ///
    /// - parameters:
    ///     - cancelled: true iff the request was cancelled
    ///     - result: if the request was successful, will contain details of the success
    typealias OAAuthenticationHandler = (cancelled: Bool, result: OAResult?)

    // MARK: - Properties

    /// user presentable name of authenticator
    var authenticatorName: String { get }

    // MARK: - Methods

    /// attempt OAuth authentication using this authenticator
    ///
    /// - Parameter withChallenge: Challenge string
    /// - Returns: Routine to invoke as result of the request
    func authorize(withChallenge: String) async throws -> OAAuthenticationHandler

    /// attempt to logout any cached user results
    ///
    /// - parameters:
    ///     - onCompletion: routine to invoke on completion of request
    func signOut() async throws

    /// handle an open url request from the application, this may be required to complete
    /// some varieties of OAuth
    ///
    /// - parameters:
    ///     - url: url being opened
    ///     - sourceApplication: name of application originating request
    func handleOpen(url: URL, sourceApplication: String?) -> Bool
}
