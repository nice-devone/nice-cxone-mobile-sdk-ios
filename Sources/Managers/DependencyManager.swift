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

final class DependencyManager: Sendable {

    // MARK: - Services

    let socketService: SocketService
    private let eventsService: EventsService
    private let welcomeMessageManager: WelcomeMessageManager

    private let connection = SafeAccessContainer<ConnectionProvider?>(nil)
    private let customer = SafeAccessContainer<CustomerProvider?>(nil)
    private let customerFields = SafeAccessContainer<CustomerCustomFieldsProvider?>(nil)
    private let contactFields = SafeAccessContainer<ContactCustomFieldsProvider?>(nil)
    private let threads = SafeAccessContainer<ChatThreadListProvider?>(nil)
    private let analytics = SafeAccessContainer<AnalyticsProvider?>(nil)
    private let proactiveActions = SafeAccessContainer<ProactiveActionProvider?>(nil)

    // MARK: - Properties
    
    var broadcaster: EventBroadcaster {
        socketService.broadcaster
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
        connection.mutate { stored -> ConnectionProvider in
            if let stored {
                return stored
            }

            let provider = ConnectionService(
                customer: resolve(),
                threads: resolve(),
                customerFields: resolve(),
                socketService: socketService,
                eventsService: eventsService,
                broadcaster: broadcaster
            )
            provider.registerListeners.mutate { content in
                content = { [weak self] in self?.registerListeners() }
            }

            stored = provider
            return provider
        }
    }

    func resolve() -> CustomerProvider {
        customer.mutate { stored -> CustomerProvider in
            if let stored {
                return stored
            }

            let provider = CustomerService(
                socketService: socketService,
                threads: resolve(),
                broadcaster: broadcaster
            )
            stored = provider
            return provider
        }
    }

    func resolve() -> CustomerCustomFieldsProvider {
        customerFields.mutate { stored -> CustomerCustomFieldsProvider in
            if let stored {
                return stored
            }

            let provider = CustomerCustomFieldsService(
                socketService: socketService,
                eventsService: eventsService
            )
            stored = provider
            return provider
        }
    }

    func resolve() -> ContactCustomFieldsProvider {
        contactFields.mutate { stored -> ContactCustomFieldsProvider in
            if let stored {
                return stored
            }

            let provider = ContactCustomFieldsService(
                socketService: socketService,
                eventsService: eventsService
            )
            stored = provider
            return provider
        }
    }

    func resolve() -> ChatThreadListProvider {
        threads.mutate { stored -> ChatThreadListProvider in
            if let stored {
                return stored
            }

            let provider = ChatThreadListService(
                contactCustomFields: resolve(),
                customerCustomFields: resolve(),
                socketService: socketService,
                eventsService: eventsService,
                welcomeMessageManager: welcomeMessageManager,
                broadcaster: broadcaster
            )
            stored = provider
            return provider
        }
    }

    func resolve() -> AnalyticsProvider {
        analytics.mutate { stored -> AnalyticsProvider in
            if let stored {
                return stored
            }

            let provider = AnalyticsService(socketService: socketService)
            stored = provider
            return provider
        }
    }

    func resolve() -> ProactiveActionProvider {
        proactiveActions.mutate { stored -> ProactiveActionProvider in
            if let stored {
                return stored
            }

            let provider = ProactiveActionService(socketService: socketService, customerCustomFields: resolve(), threads: resolve())
            stored = provider
            return provider
        }
    }
}

// MARK: - Private methods

private extension DependencyManager {

    func registerListeners() {
        // Register listeners for thread list service
        let threads: ChatThreadListProvider = resolve()
        (threads as? ChatThreadListService)?.addListeners()

        let proactiveActions: ProactiveActionProvider = resolve()
        (proactiveActions as? ProactiveActionService)?.addListeners()
    }
}
