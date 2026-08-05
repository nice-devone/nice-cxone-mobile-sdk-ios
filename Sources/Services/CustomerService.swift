//
// Copyright (c) 2021-2026. NICE Ltd. All rights reserved.
//
// Licensed under the NICE License;
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//    https://github.com/nice-devone/nice-cxone-mobile-sdk-ios/blob/main/LICENSE
//
// TO THE EXTENT PERMITTED BY APPLICABLE LAW, THE CXONE MOBILE SDK IS PROVIDED ON
// AN "AS IS" BASIS. NICE HEREBY DISCLAIMS ALL WARRANTIES AND CONDITIONS, EXPRESS
// OR IMPLIED, INCLUDING (WITHOUT LIMITATION) WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE, NON-INFRINGEMENT, AND TITLE.
//

import CXoneGuideUtility
import Foundation

final class CustomerService: Sendable {

    // MARK: - Properties
    
    let broadcaster: EventBroadcaster
    let socketService: SocketService
    
    private let threadsService: ChatThreadListService?
    
    private let _firstName = SafeAccessContainer<String?>(nil)
    private let _lastName = SafeAccessContainer<String?>(nil)

    private var firstName: String? {
        get { _firstName.content }
        set {
            _firstName.mutate { content in
                content = newValue
            }
        }
    }

    private var lastName: String? {
        get { _lastName.content }
        set {
            _lastName.mutate { content in
                content = newValue
            }
        }
    }
    
    private var connectionContext: ConnectionContext {
        socketService.connectionContext
    }

    // MARK: - Init
    
    init(
        socketService: SocketService,
        threads: ChatThreadListProvider,
        broadcaster: EventBroadcaster
    ) {
        self.socketService = socketService
        self.threadsService = threads as? ChatThreadListService
        self.broadcaster = broadcaster
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
    
    func setConnectionToken(_ token: String, expiresAt: Date) {
        guard !token.isEmpty else {
            LogManager.warning("setConnectionToken called with empty token — ignoring")
            return
        }

        LogManager.trace("Providing fresh connection token")

        // Clear any lingering explicit-flow credentials so `ConnectionContext.authenticationType`
        // deterministically resolves to `.oAuthImplicit` — otherwise switching from an explicit
        // session back to implicit could leave stale `authorizationCode` / `codeVerifier` in place.
        connectionContext.authorizationCode = ""
        connectionContext.codeVerifier = ""
        connectionContext.transactionToken = nil
        connectionContext.connectionToken = token
        connectionContext.connectionTokenExpiresAt = expiresAt
    }

    func setTokenDelegateListener(_ listener: TokenDelegateListener?) {
        LogManager.trace("\(listener == nil ? "Removing" : "Setting") token delegate listener")

        connectionContext.tokenDelegateListener = listener
    }

    func setAuthorizationCode(_ code: String) {
        LogManager.trace("Setting authorization code for explicit OAuth flow")

        // Clear any lingering implicit-flow connection token so `ConnectionContext.authenticationType`
        // deterministically resolves to `.oAuthExplicit` — otherwise a previously-set `connectionToken`
        // (non-empty) forces the resolver into `.oAuthImplicit` and this explicit credential is ignored.
        connectionContext.connectionToken = nil
        connectionContext.connectionTokenExpiresAt = nil
        connectionContext.transactionToken = nil
        connectionContext.authorizationCode = code
    }

    func setCodeVerifier(_ verifier: String) {
        LogManager.trace("Setting code verifier for explicit OAuth flow")

        // Clear any lingering implicit-flow connection token so `ConnectionContext.authenticationType`
        // deterministically resolves to `.oAuthExplicit` — otherwise a previously-set `connectionToken`
        // (non-empty) forces the resolver into `.oAuthImplicit` and this explicit credential is ignored.
        connectionContext.connectionToken = nil
        connectionContext.connectionTokenExpiresAt = nil
        connectionContext.transactionToken = nil
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

    func createCustomer(with customerId: String) {
        LogManager.trace("Creating a customer identitiy")
        
        connectionContext.customer = CustomerIdentityDTO(idOnExternalPlatform: customerId, firstName: self.firstName, lastName: self.lastName)
        
        self.firstName = nil
        self.lastName = nil
    }
}
