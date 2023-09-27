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

/// The implementation of the interface for interacting with chat features of the CXone platform.
public class CXoneChat: ChatProvider {
    
    // MARK: - Static properties
    
    /// The version of the CXone chat SDK.
    public static var version: String = "1.2.0"
    
    /// The singleton instance of the CXone chat SDK.
    public static var shared: ChatProvider = CXoneChat(
        socketService: SocketService(keychainSwift: KeychainSwift(), session: .shared, dateProvider: DateProviderImpl())
    )
    
    // MARK: - Public properties
    
    /// The handler for the chat events.
    public weak var delegate: CXoneChatDelegate? {
        didSet {
            (threads as? ChatThreadsService)?.delegate = delegate
            socketDelegateManager.delegate = delegate
        }
    }
    
    /// The handler for the logs occured in CXoneChat.
    public weak var logDelegate: LogDelegate? {
        get { LogManager.delegate }
        set { LogManager.delegate = newValue }
    }
    
    // MARK: - API providers
    
    /// The provider for connection related properties and methods.
    public var connection: ConnectionProvider {
        resolver.resolve()
    }
    /// The provider for customer related properties and methods.
    public var customer: CustomerProvider {
        resolver.resolve()
    }
    /// The provider for customer chat fields related properties and methods.
    public var customerCustomFields: CustomerCustomFieldsProvider {
        resolver.resolve()
    }
    /// The provider for thread related properties and methods.
    public var threads: ChatThreadsProvider {
        resolver.resolve()
    }
    /// The provider for report related properties and methods.
    public var analytics: AnalyticsProvider {
        resolver.resolve()
    }
    
    // MARK: - Internal properties
    
    let socketDelegateManager: SocketDelegateManager
    
    // MARK: - Private properties
    
    private let resolver: DependencyManager
    
    // MARK: - Init
    
    init(socketService: SocketService) {
        self.resolver = DependencyManager(socketService: socketService)
        self.socketDelegateManager = resolver.resolve()
    }
    
    // MARK: - Static methods
    
    /// Signs the customer out and disconnects from the CXone service.
    public static func signOut() {
        (shared.connection as? ConnectionService)?.signOut()
        
        UserDefaults.standard.removeObject(forKey: "welcomeMessage")
        
        shared = CXoneChat(socketService: SocketService(keychainSwift: KeychainSwift(), session: .shared, dateProvider: DateProviderImpl()))
    }
    
    /// Configures internal logger to be able to detect errors, warnings or even trace chat flow.
    ///
    /// - Parameters:
    ///    - level: Specifies level of records to be presented in the console. Lower levels are ignored.
    ///    - verbository: Specifies verbosity of information in the log record.
    public static func configureLogger(level: LogManager.Level, verbosity: LogManager.Verbosity) {
        LogManager.configure(level: level, verbosity: verbosity)
    }
}
