import Foundation
import KeychainSwift

protocol ConnectionContext {
    
    var keychainSwift: KeychainSwift { get set }
    
    /// The token of the device for push notifications.
    var deviceToken: String { get set }
    
    /// The code used for login with OAuth.
    var authorizationCode: String { get set }
    
    /// The code verifier used for OAuth (if PKCE is required).
    var codeVerifier: String { get set }
    
    /// The unique contact id for the last loaded thread.
    var contactId: String? { get set }
    
    /// The current channel configuration for currently connected CXone session.
    var channelConfig: ChannelConfigurationDTO { get set }
    
    /// The id of the brand for the chat.
    var brandId: Int { get set }
    
    /// The id of the channel for the chat.
    var channelId: String { get set }
    
    /// The id generated for the destination.
    var destinationId: UUID { get set }
    
    /// The environment/location to use for CXone.
    var environment: EnvironmentDetails { get set }
    
    /// An object that coordinates a group of related, network data transfer tasks.
    var session: URLSession { get }
    
    var isConnected: Bool { get }
    
    var visitorId: UUID? { get set }

    var visitDetails: CurrentVisitDetails? { get set }

    var customer: CustomerIdentityDTO? { get set }
    
    /// The auth token received from authorizing the customer. Only present in OAuth flow.
    var accessToken: AccessTokenDTO? { get }
    
    func setAccessToken(_ token: AccessTokenDTO?) throws
    
    func clear()
}

extension ConnectionContext {
    var visitId: UUID? {
        visitDetails?.visitId
    }
}

struct CurrentVisitDetails: Codable, Equatable {
    let visitId: UUID
    let expires: Date
}
