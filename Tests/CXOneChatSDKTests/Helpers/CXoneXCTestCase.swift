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

import XCTest
@testable import CXoneChatSDK

open class CXoneXCTestCase: XCTestCase {
    
    // MARK: - Properties
    
    /// "chat_51eafb4e-8829-4efe-b58c-3bc9febf18c4"
    let channelId = "chat_51eafb4e-8829-4efe-b58c-3bc9febf18c4"
    /// "https://channels-de-na1.niceincontact.com/chat/1.0/brand/1386/channel"
    let chatURL = "https://channels-de-na1.niceincontact.com/chat"
    let channelURL = "https://channels-de-na1.niceincontact.com/chat/1.0/brand/1386/channel"
    /// 1386
    let brandId = 1386
    /// ""wss://chat-gateway-de-na1.niceincontact.com""
    let socketURL = "wss://chat-gateway-de-na1.niceincontact.com"
    let decoder = JSONDecoder()
    let encoder = JSONEncoder()
    
    open override class func setUp() {
        Date.provider = DateProviderMock()
    }

    lazy var eventsService: EventsService = connectionService.eventsService
    lazy var socketService = SocketServiceMock(connectionContext: ConnectionContextMock(session: urlSession))
    lazy var CXoneChat = CXoneChatSDK.CXoneChat(socketService: socketService)
    lazy var configRequestHandler = accept(url(matches: ".*/\(channelId)$"), body: resource("ChannelConfiguration", type: "json"))
    lazy var urlSession: URLSession = {
        configuration.protocolClasses = [URLProtocolMock.self]
        return URLSession(configuration: configuration)
    }()
    
    var configuration: URLSessionConfiguration = .default
    var currentExpectation = XCTestExpectation(description: "")
    var didCheckDelegate = false
    
    var threadsService: ChatThreadsService {
        CXoneChat.threads as! ChatThreadsService
    }
    var connectionService: ConnectionService {
        CXoneChat.connection as! ConnectionService
    }
    var analyticsService: AnalyticsService {
        CXoneChat.analytics as! AnalyticsService
    }
    var messagesService: MessagesService {
        threadsService.messages as! MessagesService
    }
    var customerService: CustomerService {
        CXoneChat.customer as! CustomerService
    }
    var customerFieldsService: CustomerCustomFieldsService {
        CXoneChat.customerCustomFields as! CustomerCustomFieldsService
    }
    var contactFieldsService: ContactCustomFieldsService {
        CXoneChat.threads.customFields as! ContactCustomFieldsService
    }
    var connectionContext: ConnectionContextMock {
        socketService.connectionContext as! ConnectionContextMock
    }
    
    // MARK: - Lifecycle
    
    open override func setUp() async throws {
        continueAfterFailure = false
        try await super.setUp()
        
        UserDefaultsService.shared.remove(.cachedThreadIdOnExternalPlatform)
        
        CXoneChat.add(delegate: self)

        didCheckDelegate = false
    }
    
    // MARK: - Methods
    
    func setUpConnection(
        channelConfiguration: ChannelConfigurationDTO = MockData.getChannelConfiguration(),
        isEventMessageHandlerActive: Bool = true
    ) async throws {
        if isEventMessageHandlerActive {
            // Simulate a customer reconnect event
            socketService.messageSent = { [weak self] message in
                guard message.contains("AuthorizeCustomer") else {
                    return
                }
                
                do {
                    try self?.customerService.processCustomerReconnectEvent()
                } catch {
                    XCTFail(error.localizedDescription)
                }
            }
        }
        
        try await URLProtocolMock.with(handlers: configRequestHandler) {
            CXoneChat = CXoneChatSDK.CXoneChat(socketService: socketService)

            connectionService.connectionContext.destinationId = UUID()

            try await CXoneChat.connection.prepare(environment: .NA1, brandId: brandId, channelId: channelId)
            
            connectionService.connectionContext.channelConfig = channelConfiguration

            try await CXoneChat.connection.connect()
        }
    }
}


// MARK: - CXoneChatDelegate

extension CXoneXCTestCase: CXoneChatDelegate {
    
    public func onUnexpectedDisconnect() {
        fulfillExpectationIfNeeded()
    }
    
    public func onChatUpdated(_ state: ChatState, mode: ChatMode) {
        fulfillExpectationIfNeeded()
    }
    
    public func onThreadUpdated(_ chatThread: ChatThread) {
        fulfillExpectationIfNeeded()
    }
    
    public func onThreadsUpdated(_ chatThreads: [ChatThread]) {
        fulfillExpectationIfNeeded()
    }
    
    public func onCustomEventMessage(_ messageData: Data) {
        fulfillExpectationIfNeeded()
    }
    
    public func onAgentTyping(_ isTyping: Bool, threadId: UUID) {
        fulfillExpectationIfNeeded()
    }
    
    public func onContactCustomFieldsSet() {
        fulfillExpectationIfNeeded()
    }
    
    public func onCustomerCustomFieldsSet() {
        fulfillExpectationIfNeeded()
    }
    
    public func onError(_ error: Error) {
        fulfillExpectationIfNeeded()
    }
    
    public func onTokenRefreshFailed() {
        fulfillExpectationIfNeeded()
    }
    
    public func onProactivePopupAction(data: [String: Any], actionId: UUID) {
        fulfillExpectationIfNeeded()
    }
    
    func fulfillExpectationIfNeeded() {
        if !didCheckDelegate {
            currentExpectation.fulfill()
            didCheckDelegate = true
        }
    }
}
