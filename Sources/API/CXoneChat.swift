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
import CXoneGuideUtility
import Foundation

/// The implementation of the interface for interacting with chat features of the CXone platform.
public class CXoneChat: ChatProvider {

    // MARK: - Static properties
    
    /// The singleton instance of the CXone chat SDK.
    public static var shared: ChatProvider = CXoneChat(
        socketService: SocketServiceImpl(
            connectionContext: ConnectionContextImpl(keychainService: KeychainService(), userDefaultsService: UserDefaultsServiceImpl())
        )
    )
    
    // MARK: - Public properties
    
    /// The handler for the logs occured in CXoneChat.
    public static var logWriter: LogWriter? {
        get { LogManager.instance }
        set { LogManager.instance = newValue }
    }
    
    /// Current chat state of the SDK
    ///
    /// The state defines if the SDK is prepared for API services (analytics), connected for chat features
    /// or if it needs to be prepared or connected for proper usage.
    public var state: ChatState {
        connectionContext.chatState
    }
    
    /// Chat mode defining available functionality.
    public var mode: ChatMode {
        connectionContext.chatMode
    }
    
    // MARK: - API providers
    
    /// The provider for connection related properties and methods.
    public let connection: ConnectionProvider
    /// The provider for customer related properties and methods.
    public let customer: CustomerProvider
    /// The provider for customer chat fields related properties and methods.
    public let customerCustomFields: CustomerCustomFieldsProvider
    /// The provider for thread related properties and methods.
    public let threads: ChatThreadListProvider
    /// The provider for report related properties and methods.
    public let analytics: AnalyticsProvider
    /// The provider for proactive action related properties and methods.
    public let proactiveAction: ProactiveActionProvider

    // MARK: - Internal properties
    
    let socketService: SocketService

    var connectionContext: ConnectionContext {
        resolver.connectionContext
    }
    var socketDelegateManager: SocketDelegateManager {
        resolver.socketDelegateManager
    }
    
    // MARK: - Private properties
    
    private let resolver: DependencyManager

    // MARK: - Init

    init(socketService: SocketService) {
        self.socketService = socketService

        self.resolver = DependencyManager(socketService: socketService)
        self.connection = resolver.resolve()
        self.customer = resolver.resolve()
        self.customerCustomFields = resolver.resolve()
        self.threads = resolver.resolve()
        self.analytics = resolver.resolve()
        self.proactiveAction = resolver.resolve()
    }

    /// Add a ``CXoneChatDelegate``
    ///
    /// Future delegate messages will be routed to the newly added delegate.
    ///
    /// Note: No strong reference to the delegate is maintained so the caller
    /// is responsible for its lifecycle.
    public func add(delegate: CXoneChatDelegate) {
        socketDelegateManager.add(delegate: delegate)
    }

    /// Remove a `CXoneChatDelegate``
    ///
    /// No future delegate messages will be routed to the removed delegate.
    public func remove(delegate: CXoneChatDelegate) {
        socketDelegateManager.remove(delegate: delegate)
    }

    // MARK: - Static methods
    
    /// Signs the customer out and disconnects from the CXone service.
    public static func signOut() {
        LogManager.trace("Signing out of the current brand and channel configuration and refreshing chat instance")
        
        (shared.connection as? ConnectionService)?.signOut()
        
        shared = CXoneChat(
            socketService: SocketServiceImpl(
                connectionContext: ConnectionContextImpl(keychainService: KeychainService(), userDefaultsService: UserDefaultsServiceImpl())
            )
        )
    }
}
