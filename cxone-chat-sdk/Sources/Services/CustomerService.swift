//
// Copyright (c) 2021-2023. NICE Ltd. All rights reserved.
//
// Licensed under the NICE License;
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//    https://github.com/nice-devone/nice-cxone-mobile-sdk-ios/blob/main/LICENSE
//
// TO THE EXTENT PERMITTED BY APPLICABLE LAW, THE CXONE MOBILE SDK IS PROVIDED ON
// AN “AS IS” BASIS. NICE HEREBY DISCLAIMS ALL WARRANTIES AND CONDITIONS, EXPRESS
// OR IMPLIED, INCLUDING (WITHOUT LIMITATION) WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE, NON-INFRINGEMENT, AND TITLE.
//

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
