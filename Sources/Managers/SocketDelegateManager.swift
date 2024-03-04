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

class SocketDelegateManager: SocketDelegate {
    
    // MARK: - Properties
    
    weak var delegate: CXoneChatDelegate?
    
    private let threadsService: ChatThreadsService?
    private let customerService: CustomerService?
    private let connectionService: ConnectionService?
    
    // MARK: - Init
    
    init(
        threads: ChatThreadsProvider,
        customer: CustomerProvider,
        connection: ConnectionProvider
    ) {
        self.threadsService = threads as? ChatThreadsService
        self.customerService = customer as? CustomerService
        self.connectionService = connection as? ConnectionService
    }
    
    // MARK: - Methods
    
    func handle(message: String) {
        LogManager.trace("Handling a message - \(message.formattedJSON ?? message)")
        
        do {
            let data = Data(message.utf8)
            
            if let error: ServerError = try? data.decode(), !error.message.isEmpty {
                didReceiveError(error)
            } else {
                try resolveGenericEventData(data)
            }
        } catch {
            didReceiveError(error)
        }
    }
    
    func didReceiveError(_ error: Error) {
        switch error {
        case _ where (error as? OperationError)?.errorCode == .recoveringThreadFailed:
            threadsService?.processRecoveringThreadFailedError(error)
        case _ where (error as? OperationError)?.errorCode == .customerReconnectFailed:
            do {
                try refreshToken()
            } catch {
                delegate?.onError(error)
            }
        case _ where (error as? OperationError)?.errorCode == .tokenRefreshFailed:
            delegate?.onTokenRefreshFailed()
        default:
            delegate?.onError(error)
        }
    }
    
    func didCloseConnection() {
        LogManager.trace("Websocket connection has been closed")
        
        connectionService?.connectionContext.chatState = .prepared
        
        delegate?.onUnexpectedDisconnect()
    }
    
    func refreshToken() throws {
        try connectionService?.refreshToken()
    }
}

// MARK: - Private methods

private extension SocketDelegateManager {
    
    func resolveGenericEventData(_ eventData: Data) throws {
        let event = try eventData.decode() as GenericEventDTO
        let eventType = event.eventType ?? event.postback?.eventType
        
        if let error = event.error {
            didReceiveError(error)
        }
        if let error = event.internalServerError {
            didReceiveError(error)
        }
        
        switch eventType {
        case .senderTypingStarted:
            threadsService?.processAgentTypingEvent(try eventData.decode() as AgentTypingEventDTO, isTyping: true)
        case .senderTypingEnded:
            threadsService?.processAgentTypingEvent(try eventData.decode() as AgentTypingEventDTO, isTyping: false)
        case .messageCreated:
            try threadsService?.processMessageCreatedEvent(eventData)
        case .threadRecovered:
            try threadsService?.processThreadRecoveredEvent(try eventData.decode() as ThreadRecoveredEventDTO)
        case .messageReadChanged:
            try threadsService?.processMessageReadChangeEvent(try eventData.decode() as MessageReadByAgentEventDTO)
        case .contactInboxAssigneeChanged:
            try threadsService?.processContactInboxAssigneeChangedEvent(try eventData.decode() as ContactInboxAssigneeChangedEventDTO)
        case .threadListFetched:
            try threadsService?.processThreadListFetchedEvent(event)
        case .customerAuthorized:
            try customerService?.processCustomerAuthorizedEvent(try eventData.decode() as CustomerAuthorizedEventDTO)
        case .customerReconnected:
            customerService?.processCustomerReconnectEvent()
        case .moreMessagesLoaded:
            try threadsService?.processMoreMessagesLoaded(try eventData.decode() as MoreMessagesLoadedEventDTO)
        case .threadArchived:
            threadsService?.processThreadArchivedEvent()
        case .tokenRefreshed:
            connectionService?.saveAccessToken(try eventData.decode() as TokenRefreshedEventDTO)
        case .threadMetadataLoaded:
            try threadsService?.processThreadMetadataLoadedEvent(try eventData.decode() as ThreadMetadataLoadedEventDTO)
        case .threadUpdated:
            delegate?.onThreadUpdate()
        case .fireProactiveAction:
            try connectionService?.processProactiveAction(eventData)
        case .caseStatusChanged:
            try threadsService?.processCaseStatusChangedEvent(try eventData.decode() as CaseStatusChangedEventDTO)
        case .some:
            LogManager.info("Trying to handle unknown message event type - \(String(describing: eventType))")
        case .none:
            break
        }
    }
}
