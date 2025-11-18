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

class ProactiveActionService {
    
    // MARK: - Properties
    
    private let socketService: SocketService
    private let customerCustomFieldsService: CustomerCustomFieldsService?
    private let threadsService: ChatThreadListService?
    
    // MARK: - Protocol Properties
    
    var events: AnyPublisher<any ReceivedEvent, Never> {
        socketService.events
    }
    var cancellables: [AnyCancellable] {
        get { socketService.cancellables }
        set { socketService.cancellables = newValue }
    }
    
    // MARK: - Init
    
    init(socketService: SocketService, customerCustomFields: CustomerCustomFieldsProvider, threads: ChatThreadListProvider) {
        self.socketService = socketService
        self.customerCustomFieldsService = customerCustomFields as? CustomerCustomFieldsService
        self.threadsService = threads as? ChatThreadListService
    }
}

// MARK: - EventReceiver

extension ProactiveActionService: EventReceiver {
    
    func addListeners() {
        addListener(processProactiveActionEvent)
    }
    
    /// - Throws: ``CXoneChatError/invalidThread`` if the provided ID for the thread was invalid, so the action could not be performed.
    /// - Throws: ``CXoneChatError/customerAssociationFailure`` if the SDK could not get customer identity and it may not have been set.
    /// - Throws: ``CXoneChatError/invalidParameter(_:)`` if the provided ID for the thread was invalid, so the action could not be performed.
    /// - Throws: ``CXoneChatError/invalidData`` if the conversion from object instance to data failed
    ///     or when the Data object cannot be successfully converted to a valid UTF-8 string
    func processProactiveActionEvent(_ event: ProactiveActionEventDTO) throws {
        LogManager.trace("Processing proactive action")
        
        switch event.data.actionType {
        case .welcomeMessage:
            LogManager.trace("Processing proactive action of type welcome message")
            
            guard let message = event.data.data?.content.bodyText else {
                throw CXoneChatError.invalidData
            }
            
            if let fields = event.data.data?.customFields {
                customerCustomFieldsService?.updateFields(fields)
            }
            
            UserDefaultsService.shared.set(message, for: .welcomeMessage)
        case .customPopupBox:
            LogManager.trace("Ignoring proactive action of type custom popup box")
        }
    }
}
    
// MARK: - ProactiveActionProvider

extension ProactiveActionService: ProactiveActionProvider {
    
    /// - Throws: ``CXoneChatError/invalidThread`` if the provided ID for the thread was invalid, so the action could not be performed.
    /// - Throws: ``CXoneChatError/illegalThreadState`` if the chat thread is not in the correct state.
    /// - Throws: ``CXoneChatError/attachmentError`` if the provided attachment was unable to be sent.
    /// - Throws: ``CXoneChatError/notConnected`` if an attempt was made to use a method without connecting first.
    ///     Make sure you call the `connect` method first.
    /// - Throws: ``CXoneChatError/customerAssociationFailure`` if the SDK could not get customer identity and it may not have been set.
    /// - Throws: ``CXoneChatError/missingParameter(_:)`` if attachments upload `url` has not been set properly or attachment uploaded data object is missing
    /// - Throws: ``CXoneChatError/serverError`` if the server experienced an internal error and was unable to perform the action.
    /// - Throws: ``CXoneChatError/invalidParameter(_:)`` if the threadsService is not correctly registered.
    /// - Throws: ``CXoneChatError/invalidParameter(_:)`` if the the outbound message has no ``postback``, empty ``text``, and empty ``attachments``.
    /// - Throws: ``CXoneChatError/noSuchFile`` if an attached file could not be found.
    /// - Throws: ``CXoneChatError/invalidFileSize`` if size of the attachment exceeds the allowed size
    /// - Throws: ``CXoneChatError/invalidFileType`` if type of the attachment is not included in the allowed file MIME type
    /// - Throws: ``CXoneChatError/invalidData`` if the conversion from object instance to data failed
    ///     or when the Data object cannot be successfully converted to a valid UTF-8 string
    /// - Throws: ``CXoneChatError/eventTimeout`` if the SDK did not receive a response within the specified time.
    /// - Throws: ``EncodingError.invalidValue(_:_:)`` if the given value is invalid in the current context for this format.
    /// - Throws: ``URLError.badServerResponse`` if the URL Loading system received bad data from the server.
    /// - Throws: ``NSError`` object that indicates why the request failed
    /// - Throws: An error in the Cocoa domain, if `url` cannot be read.
    /// - Throws: An error if any value throws an error during encoding.
    func trigger(_ action: ProactiveActionTriggerType) async throws {
        switch action {
        case .refreshSession(let entity):
            // Use the button's postback directly (which contains the session expiration data)
            guard let service = try threadsService?.provider(for: entity.threadId) as? ChatThreadService else {
                throw CXoneChatError.invalidParameter("threadService")
            }
            
            try await service.send(
                message: OutboundMessage(text: entity.refreshButton.text, postback: entity.refreshButton.postback),
                parameters: [MessageParameter.isInactivityPopupAnswer: .bool(true)]
            )
        case .expireSession(let entity):
            // Use the button's postback directly (which contains the session expiration data)
            guard let service = try threadsService?.provider(for: entity.threadId) as? ChatThreadService else {
                throw CXoneChatError.invalidParameter("threadService")
            }
            
            try await service.send(
                message: OutboundMessage(text: entity.expireButton.text, postback: entity.expireButton.postback),
                parameters: [MessageParameter.isInactivityPopupAnswer: .bool(true)]
            )
        }
    }
}
