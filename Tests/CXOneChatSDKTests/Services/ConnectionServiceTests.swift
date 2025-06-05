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
@testable import CXoneChatSDK
import Mockable
import XCTest

@available(iOS 16.0, *)
class ConnectionServiceTests: XCTestCase {

    // MARK: - Properties
    
    private let customer = MockCustomerProvider()
    private let threads = MockChatThreadListProvider()
    private let customerCustomFields = MockCustomerCustomFieldsProvider()
    private let socketService = MockSocketService()
    private let connectionContext = MockConnectionContext()
    private let dateProvider = DateProviderMock()
    private let uuidProvider = MockUUIDProvider()
    private let session = MockURLSessionProtocol()
    private let subject = PassthroughSubject<ReceivedEvent, Never>()
    private let delegate = MockCXoneChatDelegate()
    
    private var service: ConnectionService?
    
    private lazy var events = subject.eraseToAnyPublisher()
    private lazy var eventsService = EventsService(connectionContext: connectionContext)
    
    private static let brandId = 1386
    private static let channelId = "chat_51eafb4e-8829-4efe-b58c-3bc9febf18c4"
    private static let visitorId = UUID()
    private static let chatURL = "https://channels-de-na1.niceincontact.com/chat"
    private static let channelURL = "https://channels-de-na1.niceincontact.com/chat/1.0/brand/1386/channel"
    private static let socketURL = "wss://chat-gateway-de-na1.niceincontact.com"
    
    // MARK: - Lifecycle
    
    override func setUp() {
        given(socketService)
            .events.willReturn(events)
            .connectionContext.willReturn(connectionContext)
        
        given(connectionContext)
            .session.willReturn(session)
        
        service = ConnectionService(
            customer: customer,
            threads: threads,
            customerFields: customerCustomFields,
            socketService: socketService,
            eventsService: eventsService,
            delegate: delegate
        )
        service?.registerListeners = { [weak self] in
            self?.service?.addListeners()
            (self?.threads as? ChatThreadListService)?.addListeners()
        }
        
        XCTAssertNotNil(service)
    }
    
    // MARK: - Tests
    
    func testGetChannelConfigurationEnvironmentThrowsBadServerResponse() async {
        given(session)
            .data(for: .any, delegate: .any).willThrow(NSError(domain: "incorrect URL", code: -1))
        
        await XCTAssertAsyncThrowsError(try await service!.getChannelConfiguration(environment: .NA1, brandId: .min, channelId: "")) { error in
            self.XCTAssertIs(error, NSError.self)
        }
    }
    
    func testGetChannelConfigurationEnvironmentNoThrow() async throws {
        given(session)
            .data(for: .any, delegate: .any).willProduce { _, _ in
                let data = try! JSONEncoder().encode(MockData.getChannelConfiguration(isMultithread: true))
                
                return (data, URLResponse())
            }
        
        let configuration = try await service!.getChannelConfiguration(environment: .NA1, brandId: Self.brandId, channelId: Self.channelId)
        
        XCTAssertEqual(configuration.hasMultipleThreadsPerEndUser, true)
    }
    
    func testGetChannelConfigurationChatURLThrowsBadServerResponse() async {
        given(session)
            .data(for: .any, delegate: .any).willThrow(NSError(domain: "incorrect URL", code: -1))
        
        await XCTAssertAsyncThrowsError(try await service!.getChannelConfiguration(chatURL: "", brandId: .min, channelId: "")) { error in
            self.XCTAssertIs(error, NSError.self)
        }
    }
    
    func testGetChannelConfigurationChatURLNoThrow() async throws {
        given(session)
            .data(for: .any, delegate: .any).willProduce { _, _ in
                let data = try! JSONEncoder().encode(MockData.getChannelConfiguration(isMultithread: true))
                
                return (data, URLResponse())
            }
        
        let configuration = try await service!.getChannelConfiguration(chatURL: Self.chatURL, brandId: Self.brandId, channelId: Self.channelId)
        
        XCTAssertEqual(configuration.hasMultipleThreadsPerEndUser, true)
    }
    
    func testPrepareWhilePreparingNoThrow() async throws {
        given(connectionContext)
            .chatState.willReturn(.preparing)
        
        try await service!.prepare(environment: .NA1, brandId: Self.brandId, channelId: Self.channelId)
    }
    
    func testPrepareThrowsIllegalChatState() async {
        given(connectionContext)
            .chatState.willReturn(.ready)
        
        await XCTAssertAsyncThrowsError(try await service!.prepare(environment: .NA1, brandId: Self.brandId, channelId: Self.channelId)) { error in
            XCTAssertEqual(error as! CXoneChatError, .illegalChatState)
        }
    }
    
    func testPrepareSuccess() async throws {
        let expectation = XCTestExpectation(description: "testPrepareSuccess")
        
        given(session)
            .data(for: .any, delegate: .any).willProduce { _, _ in
                let data = try! JSONEncoder().encode(MockData.getChannelConfiguration(isMultithread: true))
                
                return (data, URLResponse())
            }
        
        given(connectionContext)
            .visitorId.willReturn(nil)
            .customer.willReturn(nil)
            .brandId.willReturn(Self.brandId)
            .channelId.willReturn(Self.channelId)
            .environment.willReturn(CustomEnvironment(chatURL: Self.chatURL, socketURL: Self.socketURL))
            .channelConfig.willReturn(MockData.getChannelConfiguration(isMultithread: true))
            .chatState.willReturn(.initial)
            .deviceToken.willReturn(nil)
        
        given(delegate)
            .onChatUpdated(.any, mode: .any).willProduce { _, _ in
                expectation.fulfill()
                return ()
            }
        try await service!.prepare(chatURL: Self.chatURL, socketURL: Self.socketURL, brandId: Self.brandId, channelId: Self.channelId)
        
        await fulfillment(of: [expectation], timeout: 10.0)
    }
    
    func testConnectWhileConnectingNoThrow() async throws {
        given(connectionContext)
            .chatState.willReturn(.connecting)
        
        try await service!.connect()
    }
    
    func testConnectWhileAlreadyConnected() async throws {
        let expectation = XCTestExpectation(description: "testConnectWhileAlreadyConnected")
        
        given(connectionContext)
            .chatState.willReturn(.connected)
            .channelConfig.willReturn(MockData.getChannelConfiguration())
        
        given(delegate)
            .onChatUpdated(.any, mode: .any).willProduce { _, _ in
                expectation.fulfill()
                return ()
            }
        
        try await service!.connect()
        
        await fulfillment(of: [expectation], timeout: 10.0)
    }
    
    func testConnectThrowsIllegalChatState() async throws {
        given(connectionContext)
            .chatState.willReturn(.initial)
        
        await XCTAssertAsyncThrowsError(try await service!.connect()) { error in
            XCTAssertEqual(error as! CXoneChatError, .illegalChatState)
        }
    }
    
    func testConnectOfflineLivechat() async throws {
        let expectation = XCTestExpectation(description: "testConnectOfflineLivechat")
        
        given(connectionContext)
            .chatState.willReturn(.prepared)
            .channelConfig.willReturn(MockData.getChannelConfiguration(isOnline: false, isLiveChat: true))
        
        given(delegate)
            .onChatUpdated(.any, mode: .any).willProduce { _, _ in
                expectation.fulfill()
                return ()
            }
        
        try await service!.connect()
        
        await fulfillment(of: [expectation], timeout: 10.0)
    }
    
    func testConnectThrowsCustomerAssociationFailure() async throws {
        given(connectionContext)
            .visitorId.willReturn(nil)
            .customer.willReturn(nil)
            .brandId.willReturn(Self.brandId)
            .authorizationCode.willReturn("")
            .codeVerifier.willReturn("")
            .channelId.willReturn(Self.channelId)
            .environment.willReturn(CustomEnvironment(chatURL: Self.chatURL, socketURL: Self.socketURL))
            .channelConfig.willReturn(MockData.getChannelConfiguration(isMultithread: true))
            .chatState.willReturn(.prepared)
            .deviceToken.willReturn(nil)
        
        given(socketService)
            .cancellables.willReturn([])
            .connect(socketURL: .any).willReturn()
            .disconnect(unexpectedly: .any).willReturn()
        
        given(delegate)
            .onChatUpdated(.any, mode: .any).willReturn()
        
        await XCTAssertAsyncThrowsError(try await service!.connect()) { error in
            XCTAssertEqual(error as! CXoneChatError, .customerAssociationFailure)
        }
    }
    
    func testDisconnectWhilePreparingNoThrow() async {
        let expectation = XCTestExpectation(description: "testConnectOfflineLivechat")
        expectation.isInverted = true
        
        given(connectionContext)
            .chatState.willReturn(.preparing)
        
        given(delegate)
            .onChatUpdated(.any, mode: .any).willProduce { _, _ in
                expectation.fulfill()
                return ()
            }
        
        service!.disconnect()
        
        await fulfillment(of: [expectation], timeout: 1.0)
    }
    
    func testDisconnectWhileOfflineNoThrow() async {
        let expectation = XCTestExpectation(description: "testConnectOfflineLivechat")
        expectation.isInverted = true
        
        given(connectionContext)
            .chatState.willReturn(.offline)
        
        given(delegate)
            .onChatUpdated(.any, mode: .any).willProduce { _, _ in
                expectation.fulfill()
                return ()
            }
        
        service!.disconnect()
        
        await fulfillment(of: [expectation], timeout: 1.0)
    }
    
    func testDisconnectSuccess() async {
        let expectation = XCTestExpectation(description: "testConnectOfflineLivechat")
        
        given(socketService)
            .disconnect(unexpectedly: .any).willProduce { _ in
                expectation.fulfill()
            }
        
        given(connectionContext)
            .chatState.willReturn(.connected)
        
        service!.disconnect()
        
        await fulfillment(of: [expectation], timeout: 1.0)
    }
    
    func testExecuteTriggerThrowsIllegalChatState() async throws {
        given(connectionContext)
            .chatState.willReturn(.prepared)
        
        await XCTAssertAsyncThrowsError(try await service!.executeTrigger(UUID())) { error in
            XCTAssertEqual(error as! CXoneChatError, .illegalChatState)
        }
    }
    
    func testExecuteTriggerThrowsNotConnected() async {
        given(connectionContext)
            .chatState.willReturn(.connected)
        
        given(socketService)
            .checkForConnection().willThrow(CXoneChatError.notConnected)
        
        await XCTAssertAsyncThrowsError(try await service!.executeTrigger(UUID())) { error in
            XCTAssertEqual(error as! CXoneChatError, .notConnected)
        }
    }
    
    func testExecuteTriggerThrowsCustomerVisitorAssociationFailre() async {
        given(connectionContext)
            .visitorId.willReturn(nil)
            .chatState.willReturn(.connected)
        
        given(socketService)
            .checkForConnection().willReturn()
        
        await XCTAssertAsyncThrowsError(try await service!.executeTrigger(UUID())) { error in
            XCTAssertEqual(error as! CXoneChatError, .customerVisitorAssociationFailure)
        }
    }
    
    func testExecuteTriggerThrowsCustomerAssociationFailre() async {
        given(connectionContext)
            .visitorId.willReturn(UUID())
            .customer.willReturn(nil)
            .chatState.willReturn(.connected)
        
        given(socketService)
            .checkForConnection().willReturn()
        
        await XCTAssertAsyncThrowsError(try await service!.executeTrigger(UUID())) { error in
            XCTAssertEqual(error as! CXoneChatError, .customerAssociationFailure)
        }
    }
    

    func testExecuteTriggerNoThrow() async throws {
        let expectation = XCTestExpectation(description: "testExecuteTriggerNoThrow")
        
        given(connectionContext)
            .visitorId.willReturn(UUID())
            .customer.willReturn(MockData.customerIdentity)
            .brandId.willReturn(Self.brandId)
            .authorizationCode.willReturn("")
            .codeVerifier.willReturn("")
            .channelId.willReturn(Self.channelId)
            .chatState.willReturn(.connected)
            .destinationId.willReturn(UUID())
        
        given(socketService)
            .checkForConnection().willReturn()
            .send(data: .any, shouldCheck: .any).willProduce { _, _ in
                expectation.fulfill()
            }
        
        try await service!.executeTrigger(UUID())
        
        await fulfillment(of: [expectation], timeout: 1.0)
    }

    func testChannelFeatureListNonEmpty() throws {
        let data = try loadBundleData(from: "ChannelConfiguration", type: "json")
        let configuration = try JSONDecoder().decode(ChannelConfigurationDTO.self, from: data)
        
        XCTAssertFalse(configuration.settings.features.isEmpty)
        XCTAssertFalse(configuration.settings.isEnabled(feature: "liveChatLogoHidden"))
        XCTAssertTrue(configuration.settings.isEnabled(feature: "isCoBrowsingEnabled"))
        XCTAssertTrue(configuration.settings.isEnabled(feature: "UnknownFeature"))
    }
}
