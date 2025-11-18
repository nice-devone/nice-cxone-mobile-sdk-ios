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

import Foundation

class DependencyManager {
    
    // MARK: - Services
    
    private let socketService: SocketService
    private let eventsService: EventsService
    private let welcomeMessageManager: WelcomeMessageManager

    private var connection: ConnectionProvider?
    private var customer: CustomerProvider?
    private var customerFields: CustomerCustomFieldsProvider?
    private var contactFields: ContactCustomFieldsProvider?
    private var threads: ChatThreadListProvider?
    private var analytics: AnalyticsProvider?
    private var proactiveActions: ProactiveActionProvider?
    
    // MARK: - Properties
    
    var socketDelegateManager: SocketDelegateManager {
        socketService.delegateManager
    }
    var connectionContext: ConnectionContext {
        socketService.connectionContext
    }
    
    // MARK: - Init
    
    init(socketService: SocketService) {
        self.socketService = socketService
        self.welcomeMessageManager = WelcomeMessageManager()
        self.eventsService = EventsService(connectionContext: socketService.connectionContext)
    }
    
    // MARK: - Methods
    
    func resolve() -> ConnectionProvider {
        if let provider = connection {
            return provider
        }
        
        let provider = ConnectionService(
            customer: resolve(),
            threads: resolve(),
            customerFields: resolve(),
            socketService: socketService,
            eventsService: eventsService,
            delegate: socketDelegateManager
        )
        provider.registerListeners = self.registerListeners
        self.connection = provider
        
        return provider
    }
    
    func resolve() -> CustomerProvider {
        if let provider = customer {
            return provider
        }
        
        let provider = CustomerService(
            socketService: socketService,
            threads: resolve(),
            delegate: socketDelegateManager
        )
        self.customer = provider
        
        return provider
    }
    
    func resolve() -> CustomerCustomFieldsProvider {
        if let provider = customerFields {
            return provider
        }
        
        let provider = CustomerCustomFieldsService(
            socketService: socketService,
            eventsService: eventsService
        )
        self.customerFields = provider
        
        return provider
    }
    
    func resolve() -> ContactCustomFieldsProvider {
        if let provider = contactFields {
            return provider
        }
        
        let provider = ContactCustomFieldsService(
            socketService: socketService,
            eventsService: eventsService
        )
        self.contactFields = provider
        
        return provider
    }
    
    func resolve() -> ChatThreadListProvider {
        if let provider = threads {
            return provider
        }
        
        let provider = ChatThreadListService(
            contactCustomFields: resolve(),
            customerCustomFields: resolve(),
            socketService: socketService,
            eventsService: eventsService,
            welcomeMessageManager: welcomeMessageManager,
            delegate: socketDelegateManager
        )
        self.threads = provider
        
        return provider
    }
    
    func resolve() -> AnalyticsProvider {
        if let provider = analytics {
            return provider
        }
        
        let provider = AnalyticsService(socketService: socketService)
        self.analytics = provider
        
        return provider
    }
    
    func resolve() -> ProactiveActionProvider {
        if let proactiveActions {
            return proactiveActions
        }
        
        let provider = ProactiveActionService(socketService: socketService, customerCustomFields: resolve(), threads: resolve())
        self.proactiveActions = provider
        
        return provider
    }
}

// MARK: - Private methods

private extension DependencyManager {
    
    func registerListeners() {
        // Register listeners for thread list service
        let connection: ConnectionProvider = resolve()
        (connection as? ConnectionService)?.addListeners()
        
        // Register listeners for thread list service
        let threads: ChatThreadListProvider = resolve()
        (threads as? ChatThreadListService)?.addListeners()
        
        let proactiveActions: ProactiveActionProvider = resolve()
        (proactiveActions as? ProactiveActionService)?.addListeners()
    }
}
