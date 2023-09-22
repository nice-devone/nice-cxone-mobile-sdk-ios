import Foundation
import KeychainSwift

class ConnectionContextImpl: ConnectionContext {

    // MARK: - Properties
    
    var keychainSwift: KeychainSwift
    
    /// The token of the device for push notifications.
    var deviceToken: String
    
    /// The code used for login with OAuth.
    var authorizationCode: String
    
    /// The code verifier used for OAuth (if PKCE is required).
    var codeVerifier: String
    
    /// The unique contact id for the last loaded thread.
    var contactId: String?
    
    /// The current channel configuration for currently connected CXone session.
    var channelConfig: ChannelConfigurationDTO
    
    /// The id of the brand for the chat.
    var brandId: Int
    
    /// The id of the channel for the chat.
    var channelId: String
    
    /// The id generated for the destination.
    var destinationId: UUID
    
    /// The environment/location to use for CXone.
    var environment: EnvironmentDetails
    
    /// An object that coordinates a group of related, network data transfer tasks.
    let session: URLSession
    
    var isConnected: Bool { channelId != "" && brandId != .min && visitorId != nil && customer != nil }
    
    var visitorId: UUID? {
        get {
            guard let visitorId = UserDefaults.standard.object(forKey: "visitorId") as? Data else {
                return nil
            }
                
            return try? JSONDecoder().decode(UUID.self, from: visitorId)
        }
        set {
            guard let encodedVisitorId = try? JSONEncoder().encode(newValue) else {
                LogManager.error(CXoneChatError.missingParameter("visitorId"))
                return
            }
            UserDefaults.standard.set(encodedVisitorId, forKey: "visitorId")
        }
    }

    var visitDetailsStore: CurrentVisitDetails?
    var visitDetails: CurrentVisitDetails? {
        get {
            if visitDetailsStore == nil {
                guard let data = UserDefaults.standard.object(forKey: "visitDetails") as? Data else {
                    return nil
                }

                visitDetailsStore = try? JSONDecoder().decode(CurrentVisitDetails.self, from: data)
            }

            return visitDetailsStore
        }
        set {
            if visitDetailsStore != newValue {
                visitDetailsStore = newValue
                
                if let data = try? JSONEncoder().encode(newValue) {
                    UserDefaults.standard.set(data, forKey: "visitDetails")
                } else {
                    UserDefaults.standard.removeObject(forKey: "visitDetails")
                }
            }
        }
    }

    var customer: CustomerIdentityDTO? {
        get {
            guard let customerData = UserDefaults.standard.object(forKey: "customer") as? Data else {
                return nil
            }
            
            return try? JSONDecoder().decode(CustomerIdentityDTO.self, from: customerData)
        }
        set {
            guard let encodedCustomer = try? JSONEncoder().encode(newValue) else {
                LogManager.error(CXoneChatError.missingParameter("encodedCustomer"))
                return
            }
            
            UserDefaults.standard.set(encodedCustomer, forKey: "customer")
        }
    }
    
    /// The auth token received from authorizing the customer. Only present in OAuth flow.
    var accessToken: AccessTokenDTO? {
        guard let accessTokenData = keychainSwift.getData("accessToken") else {
            return nil
        }
        
        return try? JSONDecoder().decode(AccessTokenDTO.self, from: accessTokenData)
    }

    init(
        keychainSwift: KeychainSwift,
        session: URLSession,
        environment: EnvironmentDetails = CustomEnvironment(chatURL: "", socketURL: ""),
        brandId: Int = .min,
        deviceToken: String = "",
        authorizationCode: String = "",
        codeVerifier: String = "",
        contactId: String? = nil,
        channelConfig: ChannelConfigurationDTO = ChannelConfigurationDTO(
            settings: ChannelSettingsDTO(
                hasMultipleThreadsPerEndUser: false,
                isProactiveChatEnabled: false
            ),
            isAuthorizationEnabled: false,
            prechatSurvey: nil,
            contactCustomFieldDefinitions: [],
            customerCustomFieldDefinitions: []
        ),
        channelId: String = "",
        destinationId: UUID = UUID(),
        visitDetailsStore: CurrentVisitDetails? = nil
    ) {
        self.keychainSwift = keychainSwift
        self.deviceToken = deviceToken
        self.authorizationCode = authorizationCode
        self.codeVerifier = codeVerifier
        self.contactId = contactId
        self.channelConfig = channelConfig
        self.brandId = brandId
        self.channelId = channelId
        self.destinationId = destinationId
        self.environment = environment
        self.session = session
        self.visitDetailsStore = visitDetailsStore
    }

    // MARK: - Methods
    
    func setAccessToken(_ token: AccessTokenDTO?) throws {
        guard let encodedToken = try? JSONEncoder().encode(token) else {
            throw CXoneChatError.missingParameter("encodedToken")
        }
        
        keychainSwift.set(encodedToken, forKey: "accessToken")
    }
    
    func clear() {
        keychainSwift.clear()
        
        UserDefaults.standard.removeObject(forKey: "visitorId")
        UserDefaults.standard.removeObject(forKey: "visitDetails")
        UserDefaults.standard.removeObject(forKey: "customer")
    }
}
