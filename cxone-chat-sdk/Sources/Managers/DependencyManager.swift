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

class DependencyManager {
    
    // MARK: - Services
    
    private let socketService: SocketService
    private let eventsService: EventsService
    
    private var connection: ConnectionProvider?
    private var customer: CustomerProvider?
    private var customerFields: CustomerCustomFieldsProvider?
    private var contactFields: ContactCustomFieldsProvider?
    private var threads: ChatThreadsProvider?
    private var messages: MessagesProvider?
    private var analytics: AnalyticsProvider?
    
    private var socketDelegateManager: SocketDelegateManager?
    
    // MARK: - Init
    
    init(socketService: SocketService) {
        self.socketService = socketService
        self.eventsService = EventsService(connectionContext: socketService.connectionContext)
    }
    
    // MARK: - Methods
    
    func resolve() -> ConnectionProvider {
        if let provider = connection {
            return provider
        }
        
        let provider = ConnectionService(socketService: socketService, eventsService: eventsService)
        self.connection = provider
        
        return provider
    }
    
    func resolve() -> CustomerProvider {
        if let provider = customer {
            return provider
        }
        
        let provider = CustomerService(connectionContext: socketService.connectionContext)
        self.customer = provider
        
        return provider
    }
    
    func resolve() -> CustomerCustomFieldsProvider {
        if let provider = customerFields {
            return provider
        }
        
        let provider = CustomerCustomFieldsService(socketService: socketService, eventsService: eventsService, dateProvider: socketService.dateProvider)
        self.customerFields = provider
        
        return provider
    }
    
    func resolve() -> ContactCustomFieldsProvider {
        if let provider = contactFields {
            return provider
        }
        
        let provider = ContactCustomFieldsService(socketService: socketService, eventsService: eventsService, dateProvider: socketService.dateProvider)
        self.contactFields = provider
        
        return provider
    }
    
    func resolve() -> MessagesProvider {
        if let provider = messages {
            return provider
        }

        let provider = MessagesService(
            contactFieldsProvider: resolve(),
            customerFieldsProvider: resolve(),
            socketService: socketService,
            eventsService: eventsService
        )
        self.messages = provider
        
        return provider
    }
    
    func resolve() -> ChatThreadsProvider {
        if let provider = threads {
            return provider
        }
        
        let provider = ChatThreadsService(
            messagesProvider: resolve(),
            customFieldsProvider: resolve(),
            customerFieldsProvider: resolve(),
            socketService: socketService,
            eventsService: eventsService
        )
        self.threads = provider
        
        return provider
    }
    
    func resolve() -> AnalyticsProvider {
        if let provider = analytics {
            return provider
        }
        
        let provider = AnalyticsService(socketService: socketService, dateProvider: socketService.dateProvider)
        self.analytics = provider
        
        return provider
    }
    
    func resolve() -> SocketDelegateManager {
        if let manager = socketDelegateManager {
            return manager
        }
        
        let manager = SocketDelegateManager(
            threads: resolve(),
            customerCustomFields: resolve(),
            analytics: resolve(),
            socketService: socketService,
            eventsService: eventsService
        )
        socketService.delegate = manager
        self.socketDelegateManager = manager
        
        return manager
    }
}
