//
// Copyright (c) 2021-2024. NICE Ltd. All rights reserved.
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

class CustomerService: CustomerProvider {
    
    // MARK: - Properties
    
    var connectionContext: ConnectionContext
    
    weak var delegate: CXoneChatDelegate?
    
    private let socketService: SocketService
    private let threadsService: ChatThreadsService?
    
    private var firstName: String?
    private var lastName: String?
    
    // MARK: - Init
    
    init(connectionContext: ConnectionContext, socketService: SocketService, threads: ChatThreadsProvider) {
        self.connectionContext = connectionContext
        self.socketService = socketService
        self.threadsService = threads as? ChatThreadsService
    }
    
    // MARK: - Implementation
    
    func get() -> CustomerIdentity? {
        connectionContext.customer.map(CustomerIdentityMapper.map)
    }
    
    func set(_ customer: CustomerIdentity?) {
        LogManager.trace("Setting customer: \(String(describing: customer))")
        
        connectionContext.customer = customer.map(CustomerIdentityMapper.map)
    }
    
    func setDeviceToken(_ token: String) {
        LogManager.trace("Setting device token")

        connectionContext.deviceToken = token
    }
    
    func setDeviceToken(_ tokenData: Data) {
        LogManager.trace("Setting device token")

        connectionContext.deviceToken = tokenData
            .map { String(format: "%02.2hhx", $0) }
            .joined()
    }
    
    func setAuthorizationCode(_ code: String) {
        LogManager.trace("Setting authorization code")

        connectionContext.authorizationCode = code
    }
    
    func setCodeVerifier(_ verifier: String) {
        LogManager.trace("Setting code verifier")

        connectionContext.codeVerifier = verifier
    }
    
    func setName(firstName: String, lastName: String) {
        if connectionContext.customer == nil {
            LogManager.trace("Caching firstName and lastName for future setting customer identity")
            
            self.firstName = firstName
            self.lastName = lastName
        } else {
            LogManager.trace("Setting customer name")
            
            connectionContext.customer?.firstName = firstName
            connectionContext.customer?.lastName = lastName
        }
    }
}

// MARK: - Internal Methods

extension CustomerService {

    func createCustomer(customerId: UUID) {
        LogManager.trace("Creating a customer identitiy")
        
        connectionContext.customer = CustomerIdentityDTO(idOnExternalPlatform: customerId.uuidString, firstName: self.firstName, lastName: self.lastName)
        
        self.firstName = nil
        self.lastName = nil
    }
}

// MARK: - Websocket Methods

extension CustomerService {
    
    /// - Throws: ``CXoneChatError/missingAccessToken`` if the customer was successfully authorized, but an access token wasn’t returned.
    /// - Throws: ``CXoneChatError/invalidThread`` if the provided ID for the thread was invalid, so the action could not be performed.
    /// - Throws: ``CXoneChatError/customerAssociationFailure`` if the SDK could not get customer identity and it may not have been set.
    /// - Throws: ``CXoneChatError/invalidParameter(_:)`` if the message services is not correctly registered.
    /// - Throws: ``EncodingError.invalidValue(_:_:)`` if the given value is invalid in the current context for this format.
    func processCustomerAuthorizedEvent(_ event: CustomerAuthorizedEventDTO) throws {
        LogManager.trace("Processing customer authorized")
        
        if connectionContext.channelConfig.isAuthorizationEnabled {
            guard let token = event.postback.data.accessToken else {
                throw CXoneChatError.missingAccessToken
            }
            
            socketService.accessToken = token
            
            connectionContext.customer = CustomerIdentityDTO(
                idOnExternalPlatform: event.postback.data.consumerIdentity.idOnExternalPlatform,
                firstName: event.postback.data.consumerIdentity.firstName?.nilIfEmpty() ?? connectionContext.customer?.firstName,
                lastName: event.postback.data.consumerIdentity.lastName?.nilIfEmpty() ?? connectionContext.customer?.lastName
            )
        }
        
        try processCustomerReconnectEvent()
    }
    
    /// - Throws: ``CXoneChatError/invalidThread`` if the provided ID for the thread was invalid, so the action could not be performed.
    /// - Throws: ``CXoneChatError/customerAssociationFailure`` if the SDK could not get customer identity and it may not have been set.
    /// - Throws: ``CXoneChatError/invalidParameter(_:)`` if the message services is not correctly registered.
    /// - Throws: ``EncodingError.invalidValue(_:_:)`` if the given value is invalid in the current context for this format.
    func processCustomerReconnectEvent() throws {
        LogManager.trace("Processing customer reconnect")
        
        connectionContext.chatState = .connected
        delegate?.onChatUpdated(connectionContext.chatState, mode: connectionContext.chatMode)
        
        try threadsService?.handleForCurrentChatMode(connectionContext.chatMode)
    }
}
