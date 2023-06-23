import Foundation
import KeychainSwift


struct ConnectionContextImpl: ConnectionContext {
    
    // MARK: - Properties
    
    var keychainSwift: KeychainSwift
    
    /// The token of the device for push notifications.
    var deviceToken = ""
    
    /// The code used for login with OAuth.
    var authorizationCode = ""
    
    /// The code verifier used for OAuth (if PKCE is required).
    var codeVerifier = ""
    
    /// The unique contact id for the last loaded thread.
    var contactId: String?
    
    /// The current channel configuration for currently connected CXone session.
    var channelConfig = ChannelConfigurationDTO(
        settings: ChannelSettingsDTO(hasMultipleThreadsPerEndUser: false, isProactiveChatEnabled: false),
        isAuthorizationEnabled: false,
        prechatSurvey: nil,
        contactCustomFieldDefinitions: [],
        customerCustomFieldDefinitions: []
    )
    
    /// The id of the brand for the chat.
    var brandId: Int = .min
    
    /// The id of the channel for the chat.
    var channelId = ""
    
    /// The id generated for the destination.
    var destinationId = UUID()
    
    /// The environment/location to use for CXone.
    var environment: EnvironmentDetails = CustomEnvironment(chatURL: "", socketURL: "")
    
    /// An object that coordinates a group of related, network data transfer tasks.
    let session: URLSession
    
    var isConnected: Bool { channelId != "" && brandId != .min && visitorId != nil && customer != nil }
    
    var visitorId: UUID? {
        get {
            guard let visitorId = keychainSwift.getData("visitorId") else {
                return nil
            }
                
            return try? JSONDecoder().decode(UUID.self, from: visitorId)
        }
        set {
            guard let encodedVisitorId = try? JSONEncoder().encode(newValue) else {
                LogManager.error(CXoneChatError.missingParameter("visitorId"))
                return
            }
            
            keychainSwift.set(encodedVisitorId, forKey: "visitorId")
        }
    }
    
    var customer: CustomerIdentityDTO? {
        get {
            guard let customerData = keychainSwift.getData("customer") else {
                return nil
            }
            
            return try? JSONDecoder().decode(CustomerIdentityDTO.self, from: customerData)
        }
        set {
            guard let encodedCustomer = try? JSONEncoder().encode(newValue) else {
                LogManager.error(CXoneChatError.missingParameter("encodedCustomer"))
                return
            }
            
            keychainSwift.set(encodedCustomer, forKey: "customer")
        }
    }
    
    /// The auth token received from authorizing the customer. Only present in OAuth flow.
    var accessToken: AccessTokenDTO? {
        guard let accessTokenData = keychainSwift.getData("accessToken") else {
            return nil
        }
        
        return try? JSONDecoder().decode(AccessTokenDTO.self, from: accessTokenData)
    }
    
    
    // MARK: - Methods
    
    func setAccessToken(_ token: AccessTokenDTO?) throws {
        guard let encodedToken = try? JSONEncoder().encode(token) else {
            throw CXoneChatError.missingParameter("encodedToken")
        }
        
        keychainSwift.set(encodedToken, forKey: "accessToken")
    }
}
