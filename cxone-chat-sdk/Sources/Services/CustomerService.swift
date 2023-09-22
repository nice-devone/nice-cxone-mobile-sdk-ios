import Foundation
import KeychainSwift

class CustomerService: CustomerProvider {
    
    // MARK: - Properties
    
    var connectionContext: ConnectionContext
    
    // MARK: - Init
    
    init(connectionContext: ConnectionContext) {
        self.connectionContext = connectionContext
    }
    
    // MARK: - Implementation
    
    func get() -> CustomerIdentity? {
        connectionContext.customer.map(CustomerIdentityMapper.map) ?? nil
    }
    
    func set(_ customer: CustomerIdentity?) {
        LogManager.trace("Setting customer: \(String(describing: customer)).")
        
        connectionContext.customer = customer.map(CustomerIdentityMapper.map) ?? nil
    }
    
    func setDeviceToken(_ token: String) {
        LogManager.trace("Setting device token.")

        connectionContext.deviceToken = token
    }
    
    func setDeviceToken(_ tokenData: Data) {
        LogManager.trace("Setting device token.")

        connectionContext.deviceToken = tokenData
            .map { String(format: "%02.2hhx", $0) }
            .joined()
    }
    
    func setAuthorizationCode(_ code: String) {
        LogManager.trace("Setting authorization code.")

        connectionContext.authorizationCode = code
    }
    
    func setCodeVerifier(_ verifier: String) {
        LogManager.trace("Setting code verifier.")

        connectionContext.codeVerifier = verifier
    }
    
    func setName(firstName: String, lastName: String) {
        LogManager.trace("Setting customer name.")
        
        if connectionContext.customer != nil {
            connectionContext.customer?.firstName = firstName
            connectionContext.customer?.lastName = lastName
        } else {
            connectionContext.customer = CustomerIdentityDTO(idOnExternalPlatform: UUID().uuidString, firstName: firstName, lastName: lastName)
        }
    }   
}
