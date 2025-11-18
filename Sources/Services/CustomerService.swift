//
// Copyright (c) 2021-2025. NICE Ltd. All rights reserved.
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

import Combine
import Foundation

class CustomerService {

    // MARK: - Properties
    
    let delegate: CXoneChatDelegate
    let socketService: SocketService
    
    private let threadsService: ChatThreadListService?
    
    private var firstName: String?
    private var lastName: String?
    
    private var connectionContext: ConnectionContext {
        socketService.connectionContext
    }

    // MARK: - Init
    
    init(
        socketService: SocketService,
        threads: ChatThreadListProvider,
        delegate: CXoneChatDelegate
    ) {
        self.socketService = socketService
        self.threadsService = threads as? ChatThreadListService
        self.delegate = delegate
    }
}

// MARK: - CustomerProvider

extension CustomerService: CustomerProvider {

    func get() -> CustomerIdentity? {
        connectionContext.customer.map(CustomerIdentityMapper.map)
    }
    
	/// - Throws: ``CXoneChatError/illegalChatState`` if the chat is already initialized.
    func set(customer: CustomerIdentity?) throws {
        guard connectionContext.chatState == .initial else {
            LogManager.error("Tried to set customer identity after chat initialization")
            
            throw CXoneChatError.illegalChatState
        }
        
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

        // Reset `accessToken` with a new authorization code for fresh authorization
        connectionContext.accessToken = nil
        
        connectionContext.authorizationCode = code
    }
    
    func setCodeVerifier(_ verifier: String) {
        LogManager.trace("Setting code verifier")

        // Reset `accessToken` with a new authorization code for fresh authorization
        connectionContext.accessToken = nil
        
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
    
    /// - Throws: ``CXoneChatError/missingAccessToken`` if the customer was successfully authorized, but an access token wasn't returned.
    /// - Throws: ``CXoneChatError/invalidThread`` if the provided ID for the thread was invalid, so the action could not be performed.
    /// - Throws: ``CXoneChatError/customerAssociationFailure`` if the SDK could not get customer identity and it may not have been set.
    /// - Throws: ``CXoneChatError/invalidParameter(_:)`` if the threadsService is not correctly registered.
    /// - Throws: ``CXoneChatError/invalidData`` when the Data object cannot be successfully converted to a valid UTF-8 string
    /// - Throws: ``CXoneChatError/unsupportedChannelConfig`` if the method being called is not supported with the current channel configuration.
    /// - Throws: ``EncodingError.invalidValue(_:_:)`` if the given value is invalid in the current context for this format.
    func processCustomerAuthorizedEvent(_ response: CustomerAuthorizedEventDTO) async throws {
        LogManager.trace("Processing customer authorized")
        
        if connectionContext.channelConfig.isAuthorizationEnabled {
            guard let token = response.postback.data.accessToken else {
                throw CXoneChatError.missingAccessToken
            }
            
            socketService.accessToken = token
            
            connectionContext.customer = CustomerIdentityDTO(
                idOnExternalPlatform: response.postback.data.consumerIdentity.idOnExternalPlatform,
                firstName: response.postback.data.consumerIdentity.firstName?.nilIfEmpty() ?? connectionContext.customer?.firstName,
                lastName: response.postback.data.consumerIdentity.lastName?.nilIfEmpty() ?? connectionContext.customer?.lastName
            )
        }
        
        try await processCustomerReconnectedEvent()
    }
    
    /// - Throws: ``CXoneChatError/invalidThread`` if the provided ID for the thread was invalid, so the action could not be performed.
    /// - Throws: ``CXoneChatError/customerAssociationFailure`` if the SDK could not get customer identity and it may not have been set.
    /// - Throws: ``CXoneChatError/invalidParameter(_:)`` if the threadsService is not correctly registered.
    /// - Throws: ``CXoneChatError/invalidData`` when the Data object cannot be successfully converted to a valid UTF-8 string
    /// - Throws: ``CXoneChatError/invalidParameter(_:)`` if the threadsService is not correctly registered.
    /// - Throws: ``CXoneChatError/unsupportedChannelConfig`` if the method being called is not supported with the current channel configuration.
    /// - Throws: ``EncodingError.invalidValue(_:_:)`` if the given value is invalid in the current context for this format.
    func processCustomerReconnectedEvent() async throws {
        LogManager.trace("Processing customer reconnect")
        
        guard let threadsService else {
            throw CXoneChatError.invalidParameter("threadService")
        }
        
        try await threadsService.handleForCurrentChatMode(connectionContext.chatMode)
    }
}
