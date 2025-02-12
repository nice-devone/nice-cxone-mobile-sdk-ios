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

import Combine
import Foundation

/// The implementation of the interface for interacting with chat features of the CXone platform.
public class CXoneChat: ChatProvider, EventReceiver {

    // MARK: - Static properties

    /// The current marketing version of the CXone chat SDK
    @available(*, deprecated, message: "Deprecated with 2.2.0. Please use version property of CXoneChatSDKModule.")
    public static var version: String = "2.3.0"
    
    /// The singleton instance of the CXone chat SDK.
    public static var shared: ChatProvider = CXoneChat(
        socketService: SocketServiceImpl(
            connectionContext: ConnectionContextImpl(keychainService: KeychainService())
        )
    )
    
    // MARK: - Public properties
    
    /// The handler for the chat events.
    @available(*, deprecated, message: "Deprecated with 2.2.0 Please use add(delegate:)")
    public weak var delegate: CXoneChatDelegate? {
        willSet {
            if let delegate = delegate {
                remove(delegate: delegate)
            }
            if let delegate = newValue {
                add(delegate: delegate)
            }
        }
    }
    
    /// The handler for the logs occured in CXoneChat.
    public weak var logDelegate: LogDelegate? {
        get { LogManager.delegate }
        set { LogManager.delegate = newValue }
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
    public let threads: ChatThreadsProvider
    /// The provider for report related properties and methods.
    public let analytics: AnalyticsProvider
    /// The connection context
    private let connectionContext: ConnectionContext

    // MARK: - Internal properties
    
    let socketDelegateManager: SocketDelegateManager
    let socketService: SocketService

    // MARK: - Private properties
    
    private let resolver: DependencyManager
    
    // MARK: - EventReceiver properties

    var events: AnyPublisher<any ReceivedEvent, Never> { socketService.events }

    var cancellables = [AnyCancellable]()

    // MARK: - Init

    init(socketService: SocketService) {
        self.socketService = socketService

        self.resolver = DependencyManager(socketService: socketService)
        self.socketDelegateManager = resolver.resolve()
        self.connection = resolver.resolve()
        self.customer = resolver.resolve()
        self.customerCustomFields = resolver.resolve()
        self.threads = resolver.resolve()
        self.analytics = resolver.resolve()
        self.connectionContext = resolver.connectionContext

        addListeners()
    }
    
    func addListeners() {
        addListener(onOperationError(_:))
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

    private func onOperationError(_ error: OperationError) {
        switch error.errorCode {
        case .recoveringThreadFailed,
                .recoveringLiveChatFailed,
                .customerReconnectFailed:
            // these are handled elsewhere
            break
        case .tokenRefreshFailed:
            socketDelegateManager.onTokenRefreshFailed()
        default:
            socketDelegateManager.onError(error)
        }
    }

    // MARK: - Static methods
    
    /// Signs the customer out and disconnects from the CXone service.
    public static func signOut() {
        LogManager.trace("Signing out of the current brand and channel configuration and refreshing chat instance")
        
        (shared.connection as? ConnectionService)?.signOut()
        
        UserDefaultsService.shared.remove(.welcomeMessage)
        UserDefaultsService.shared.remove(.cachedThreadIdOnExternalPlatform)
        
        shared = CXoneChat(
            socketService: SocketServiceImpl(
                connectionContext: ConnectionContextImpl(keychainService: KeychainService(), session: .shared)
            )
        )
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
