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

class SocketDelegateManager {
    
    // MARK: - Properties
    
    let socketService: SocketService
    
    weak var delegate: CXoneChatDelegate?
    
    private let threadsService: ChatThreadsService?
    private let customerService: CustomerService?
    private let connectionService: ConnectionService?
    
    // MARK: - Init
    
    init(
        socketService: SocketService,
        threads: ChatThreadsProvider,
        customer: CustomerProvider,
        connection: ConnectionProvider
    ) {
        self.socketService = socketService
        self.threadsService = threads as? ChatThreadsService
        self.customerService = customer as? CustomerService
        self.connectionService = connection as? ConnectionService
        
        socketService.delegate = self
    }
}

// MARK: - SocketDelegate

extension SocketDelegateManager: SocketDelegate {
    
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
        switch (error as? OperationError)?.errorCode {
        case .recoveringThreadFailed, .recoveringLiveChatFailed:
            threadsService?.processRecoveringThreadFailedError(error)
        case .customerReconnectFailed:
            do {
                try refreshToken()
            } catch {
                delegate?.onError(error)
            }
        case .tokenRefreshFailed:
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
    
    // swiftlint:disable:next function_body_length
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
        case .eventInS3:
            try socketService.downloadEventContentFromS3(try eventData.decode())
        case .senderTypingStarted:
            threadsService?.processAgentTypingEvent(try eventData.decode(), isTyping: true)
        case .senderTypingEnded:
            threadsService?.processAgentTypingEvent(try eventData.decode(), isTyping: false)
        case .messageCreated:
            try threadsService?.processMessageCreatedEvent(try eventData.decode())
        case .threadRecovered:
            try threadsService?.processThreadRecoveredEvent(try eventData.decode())
        case .messageReadChanged:
            try threadsService?.processMessageReadChangeEvent(try eventData.decode())
        case .contactInboxAssigneeChanged:
            try threadsService?.processContactInboxAssigneeChangedEvent(try eventData.decode())
        case .threadListFetched:
            try threadsService?.processThreadListFetchedEvent(event)
        case .customerAuthorized:
            try customerService?.processCustomerAuthorizedEvent(try eventData.decode())
        case .customerReconnected:
            try customerService?.processCustomerReconnectEvent()
        case .moreMessagesLoaded:
            try threadsService?.processMoreMessagesLoaded(try eventData.decode())
        case .threadArchived:
            threadsService?.processThreadArchivedEvent()
        case .tokenRefreshed:
            connectionService?.saveAccessToken(try eventData.decode())
        case .threadMetadataLoaded:
            try threadsService?.processThreadMetadataLoadedEvent(try eventData.decode())
        case .fireProactiveAction:
            try connectionService?.processProactiveAction(eventData)
        case .caseStatusChanged:
            try threadsService?.processCaseStatusChangedEvent(try eventData.decode())
        case .setPositionInQueue:
            try threadsService?.processSetPositionInQueueEvent(try eventData.decode())
        case .liveChatRecovered:
            try threadsService?.processLiveChatRecoveredEvent(try eventData.decode())
        case .custom:
            delegate?.onCustomEventMessage(eventData)
        case .some:
            LogManager.info("Trying to handle unknown message event type - \(String(describing: eventType))")
        case .none:
            break
        }
    }
}
