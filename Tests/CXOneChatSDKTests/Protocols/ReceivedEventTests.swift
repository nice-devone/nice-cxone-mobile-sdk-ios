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

@testable import CXoneChatSDK
import XCTest

final class ReceivedEventTests: XCTestCase {

    func testServerError() throws {
        try checkParsing(from: "ServerError", type: ServerError.self)
    }

    func testOperationError() throws {
        // Can't use checkParsing here because the actual forwarded event isn't the
        // same as the parsed event.
        let data = try loadBundleData(from: "OperationError", type: "json")
        let expect = try JSONDecoder().decode(GenericEventDTO.self, from: data)

        let actual = data.toReceivedEvent()

        XCTAssertEqual(
            actual as? OperationError,
            expect.error
        )
    }

    func testInternalServerError() throws {
        #warning("TBD: Test Internal Server Error deserialization")
    }

    func testEventInS3() throws {
        try checkParsing(from: "EventInS3+ThreadRecovered", type: EventInS3DTO.self)
    }

    func testAgentTypingStarted() throws {
        let event = try checkParsing(
            from: "AgentTypingStarted",
            type: AgentTypingEventDTO.self
        )

        XCTAssertEqual(event?.agentTyping, true)
    }

    func testAgentTypingEnded() throws {
        let event = try checkParsing(
            from: "AgentTypingEnded",
            type: AgentTypingEventDTO.self
        )

        XCTAssertEqual(event?.agentTyping, false)
    }

    func testMessageCreated() throws {
        try checkParsing(from: "MessageCreatedEvent", type: MessageCreatedEventDTO.self)
    }

    func testThreadRecovered() throws {
        try checkParsing(from: "ThreadRecoveredEvent", type: ThreadRecoveredEventDTO.self)
    }

    func testLivechatRecovered() throws {
        try checkParsing(from: "LivechatRecoveredEvent", type: LiveChatRecoveredDTO.self)
    }
    
    func testMessageRead() throws {
        try checkParsing(from: "MessageReadEventByAgent", type: MessageReadByAgentEventDTO.self)
    }

    func testContactInboxAssigneeChanged() throws {
        try checkParsing(
            from: "CaseInboxAssigneeChanged",
            type: ContactInboxAssigneeChangedEventDTO.self
        )
    }

    func testThreadListFetched() throws {
        let event = try checkParsing(from: "ThreadListFetchedEvent", type: GenericEventDTO.self)

        XCTAssertEqual(event?.postback?.threads?.count, 1)
    }

    func testCustomerAuthorized() throws {
        try checkParsing(from: "CustomerAuthorizedEvent", type: CustomerAuthorizedEventDTO.self)
    }

    func testCustomerReconnected() throws {
        #warning("Implement CustomerReconnected parsing test")
    }

    func testMoreMessagesLoaded() throws {
        try checkParsing(from: "MoreMessagesLoaded", type: MoreMessagesLoadedEventDTO.self)
    }

    func testThreadArchived() throws {
        try checkParsing(from: "ThreadArchived", type: GenericEventDTO.self)
    }

    func testTokenRefreshed() throws {
        #warning("Implement TokenRefreshed parsing test")
    }

    func testMetadataLoaded() throws {
        try checkParsing(
            from: "ThreadMetadataLoadedEvent",
            type: ThreadMetadataLoadedEventDTO.self
        )
    }

    func testFireProactiveAction() throws {
        try checkParsing(
            from: "FireProactiveAction+WelcomeMessage",
            type: ProactiveActionEventDTO.self
        )
    }

    func testCaseStatusChanged() throws {
        try checkParsing(from: "CaseStatusChanged", type: CaseStatusChangedEventDTO.self)
    }

    func testSetPositionInQueue() throws {
        try checkParsing(from: "SetPositionInQueue", type: SetPositionInQueueEventDTO.self)
    }

    func testLiveChatRestored() throws {
        #warning("Implement LiveChatRecovered parsing test")
    }
}

// MARK: - Helpers

private extension ReceivedEventTests {
    
    @discardableResult
    func checkParsing<Type: ReceivedEvent & Decodable & Equatable>(
        from file: String,
        type: Type.Type,
        source: StaticString = #file,
        line: UInt = #line
    ) throws -> Type? {
        var data: Data
        var expect: Type

        do {
            data = try loadBundleData(from: file, type: "json")
        } catch {
            XCTFail("Error loading \(file): \(error)", file: source, line: line)
            throw error
        }

        do {
            expect = try JSONDecoder().decode(type, from: data)
        } catch {
            XCTFail("Error parsing \(file): \(error)", file: source, line: line)
            throw error
        }

        let actual = data.toReceivedEvent() as? Type

        XCTAssertEqual(actual, expect, file: source, line: line)

        return actual
    }
}
