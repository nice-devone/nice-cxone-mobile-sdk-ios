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

class AnalyticsProviderTests: CXoneXCTestCase {

    // MARK: - Properties

    private let proactiveDetails = ProactiveActionDetails(
        id: UUID(),
        name: "Welcome message",
        type: .welcomeMessage,
        content: ProactiveActionDataMessageContent(bodyText: "Body", headlineText: "Headline")
    )
    
    private var visitDetails: CurrentVisitDetails? {
        get { connectionContext.visitDetails }
        set { connectionContext.visitDetails = newValue }
    }

    // MARK: - Tests
    
    func testSetVisitorId() async throws {
        XCTAssertNil(analyticsService.visitorId)
        
        try await setUpConnection()
        
        XCTAssertNotNil(analyticsService.visitorId)
    }

    func testViewPageIllegalChatStateThrows() async throws {
        await XCTAssertAsyncThrowsError(try await analyticsService.viewPage(title: "page", url: "url"))
    }

    func testViewPageNoVisitCreatesVisit() async throws {
        try await setUpConnection()
        
        visitDetails = nil

        let events = try await verify(sends: visit(), pageView(title: "page", url: "url")) {
            try await analyticsService.viewPage(title: "page", url: "url")
        }
        
        XCTAssertNotNil(visitDetails)

        XCTAssertEqual(visitDetails?.visitId.uuidString, events[0]["visitId"] as? String)
        XCTAssertEqual(visitDetails?.visitId.uuidString, events[1]["visitId"] as? String)

        XCTAssertEqual(Date(timeInterval: 30 * 60, since: Date.provide()), visitDetails?.expires)
    }

    func testViewPageStaleVisitCreatesVisit() async throws {
        try await setUpConnection()
        
        let oldUUID = UUID()
        visitDetails = CurrentVisitDetails(visitId: oldUUID, expires: Date(timeInterval: -1, since: Date.provide()))

        try await verify(sends: visit(), pageView(title: "page", url: "url", visitId: "*")) {
            try await analyticsService.viewPage(title: "page", url: "url")
        }

        XCTAssertNotNil(visitDetails)
        XCTAssertEqual(Date(timeInterval: 30 * 60, since: Date.provide()), visitDetails?.expires)
        XCTAssertNotEqual(oldUUID, visitDetails?.visitId)
    }

    func testViewPageCurrentVisitJustUpdatesExpires() async throws {
        try await setUpConnection()
        
        let oldUUID = UUID()
        visitDetails = CurrentVisitDetails(visitId: oldUUID, expires: Date(timeInterval: 1, since: Date.provide()))

        try await verify(sends: pageView(title: "page", url: "url")) {
            try await analyticsService.viewPage(title: "page", url: "url")
        }

        XCTAssertNotNil(visitDetails)
        XCTAssertEqual(Date(timeInterval: 30 * 60, since: Date.provide()), visitDetails?.expires)
        XCTAssertEqual(oldUUID, visitDetails?.visitId)
    }
    
    func testViewPageEndedNoConnectionThrows() async throws {
        analyticsService.lastPageViewed = PageViewEventDTO(title: "page", url: "url", timestamp: Date.provide().addingTimeInterval(-100))
        
        await XCTAssertAsyncThrowsError(try await analyticsService.viewPageEnded(title: "page", url: "url"))
    }

    func testViewPageEndedStaleVisitCreatesVisit() async throws {
        try await setUpConnection()
        
        let oldUUID = UUID()
        visitDetails = CurrentVisitDetails(visitId: oldUUID, expires: Date(timeInterval: -1, since: Date.provide()))

        try await verify(sends: visit(), pageView(title: "page", url: "url", visitId: "*")) {
            try await analyticsService.viewPage(title: "page", url: "url")
        }

        XCTAssertNotNil(visitDetails)
        XCTAssertEqual(Date(timeInterval: 30 * 60, since: Date.provide()), visitDetails?.expires)
        XCTAssertNotEqual(oldUUID, visitDetails?.visitId)
    }

    func testChatWindowOpenDisconnectedThrows() async throws {
        visitDetails = CurrentVisitDetails(visitId: UUID(), expires: Date(timeInterval: 1, since: Date.provide()))
        
        await XCTAssertAsyncThrowsError(try await analyticsService.chatWindowOpen())
    }

    func testChatWindowOpenOutOfSequenceThrows() async throws {
        await XCTAssertAsyncThrowsError(try await analyticsService.chatWindowOpen())
    }

    func testChatWindowOpen() async throws {
        try await setUpConnection()
        
        visitDetails = CurrentVisitDetails(visitId: UUID(), expires: Date(timeInterval: 1, since: Date.provide()))

        try await verify(sends: chatWindowOpen()) {
            try await analyticsService.chatWindowOpen()
        }
    }

    func testConversionDisconnectedThrows() async throws {
        visitDetails = CurrentVisitDetails(visitId: UUID(), expires: Date(timeInterval: 1, since: Date.provide()))

        await XCTAssertAsyncThrowsError(try await analyticsService.conversion(type: "sale", value: 98))
    }

    func testConversionOutOfSequenceThrows() async throws {
        await XCTAssertAsyncThrowsError(try await analyticsService.conversion(type: "sale", value: 98))
    }

    func testConversion() async throws {
        try await setUpConnection()
        
        visitDetails = CurrentVisitDetails(visitId: UUID(), expires: Date(timeInterval: 1, since: Date.provide()))

        try await verify(sends: conversion(type: "sale", amount: 98)) {
            try await analyticsService.conversion(type: "sale", value: 98)
        }
    }
    
    func testProactiveActionDisplayDisconnectedThrows() async throws {
        visitDetails = CurrentVisitDetails(visitId: UUID(), expires: Date(timeInterval: 1, since: Date.provide()))

        await XCTAssertAsyncThrowsError(try await analyticsService.proactiveActionDisplay(data: proactiveDetails))
    }

    func testProactiveActionDisplayOutOfSequenceThrows() async throws {
        await XCTAssertAsyncThrowsError(try await analyticsService.proactiveActionDisplay(data: proactiveDetails))
    }

    func testProactiveActionDisplay() async throws {
        try await setUpConnection()
        
        visitDetails = CurrentVisitDetails(visitId: UUID(), expires: Date(timeInterval: 1, since: Date.provide()))

        try await verify(sends: proactiveActionDisplayed(details: proactiveDetails)) {
            try await analyticsService.proactiveActionDisplay(data: proactiveDetails)
        }
    }
    
    func testProactiveActionClickedDisconnectedThrows() async throws {
        visitDetails = CurrentVisitDetails(visitId: UUID(), expires: Date(timeInterval: 1, since: Date.provide()))

        await XCTAssertAsyncThrowsError(try await analyticsService.proactiveActionClick(data: proactiveDetails))
    }

    func testProactiveActionClickedOutOfSequenceThrows() async throws {
        await XCTAssertAsyncThrowsError(try await analyticsService.proactiveActionClick(data: proactiveDetails))
    }

    func testProactiveActionClicked() async throws {
        try await setUpConnection()
        
        visitDetails = CurrentVisitDetails(visitId: UUID(), expires: Date(timeInterval: 1, since: Date.provide()))

        try await verify(sends: proactiveActionClicked(details: proactiveDetails)) {
            try await analyticsService.proactiveActionClick(data: proactiveDetails)
        }
    }

    func testProactiveActionSuccessDisconnectedThrows() async throws {
        visitDetails = CurrentVisitDetails(visitId: UUID(), expires: Date(timeInterval: 1, since: Date.provide()))
       
        await XCTAssertAsyncThrowsError(try await analyticsService.proactiveActionSuccess(true, data: proactiveDetails))
    }

    func testProactiveActionSuccessOutOfSequenceThrows() async throws {
        await XCTAssertAsyncThrowsError(try await analyticsService.proactiveActionSuccess(true, data: proactiveDetails))
    }

    func testProactiveActionSuccess() async throws {
        try await setUpConnection()
        
        visitDetails = CurrentVisitDetails(visitId: UUID(), expires: Date(timeInterval: 1, since: Date.provide()))

        try await verify(sends: proactiveActionSuccess(details: proactiveDetails)) {
            try await analyticsService.proactiveActionSuccess(true, data: proactiveDetails)
        }
    }

    func testProactiveActionFailureDisconnectedThrows() async throws {
        visitDetails = CurrentVisitDetails(visitId: UUID(), expires: Date(timeInterval: 1, since: Date.provide()))
        
        await XCTAssertAsyncThrowsError(try await analyticsService.proactiveActionSuccess(false, data: proactiveDetails))
    }

    func testProactiveActionFailureOutOfSequenceThrows() async throws {
        await XCTAssertAsyncThrowsError(try await analyticsService.proactiveActionSuccess(false, data: proactiveDetails))
    }

    func testProactiveActionFailure() async throws {
        try await setUpConnection()
        
        visitDetails = CurrentVisitDetails(visitId: UUID(), expires: Date(timeInterval: 1, since: Date.provide()))

        try await verify(sends: proactiveActionFailure(details: proactiveDetails)) {
            try await analyticsService.proactiveActionSuccess(false, data: proactiveDetails)
        }
    }

    func testProactiveActionFailureThrows() async throws {
        await XCTAssertAsyncThrowsError(try await analyticsService.proactiveActionSuccess(false, data: proactiveDetails))
    }
    
    func testTypingStartStartThrows() {
        XCTAssertThrowsError(try CXoneChat.threads.reportTypingStart(true, in: ChatThreadMapper.map(MockData.getThread())))
    }
    
    func testTypingStartStartNoThrow() async throws {
        try await setUpConnection()
        
        XCTAssertNoThrow(try CXoneChat.threads.reportTypingStart(true, in: ChatThreadMapper.map(MockData.getThread())))
    }
    
    func testTypingStartEndThrows() {
        XCTAssertThrowsError(try CXoneChat.threads.reportTypingStart(false, in: ChatThreadMapper.map(MockData.getThread())))
    }
    
    func testTypingStartEndNoThrow() async throws {
        try await setUpConnection()
        
        XCTAssertNoThrow(try CXoneChat.threads.reportTypingStart(false, in: ChatThreadMapper.map(MockData.getThread())))
    }
}

// MARK: - Utilities

private extension AnalyticsProviderTests {

    @discardableResult
    func verify(
        sends expects: NSDictionary...,
        file: StaticString = #file,
        line: UInt = #line,
        during: () async throws -> Void
    ) async throws -> [NSDictionary] {
        var requests = [URLRequest]()
        let expectation = expectation(description: "\(expects.count) events sent")

        try await URLProtocolMock.with(
            handlers: accept(url(matches: "/events$", method: "POST")) { request in
                requests.append(request)
                if requests.count == expects.count {
                    expectation.fulfill()
                }

                return (HTTPURLResponse(url: request.url!, statusCode: 200, httpVersion: nil, headerFields: nil)!, nil)
            }
        ) {
            try await during()

            await fulfillment(of: [expectation], timeout: 10.0)
        }

        XCTAssertEqual(expects.count, requests.count)

        return try zip(requests, expects).compactMap { (request, expect) in
            guard let body = try request.httpBodyStream.map({ try Data(stream: $0) }) ?? request.httpBody else {
                XCTFail("request has no body", file: file, line: line)
                return nil
            }
            guard let actual = try JSONSerialization.jsonObject(with: body) as? NSDictionary else {
                XCTFail("Couldn't parse request", file: file, line: line)
                return nil
            }

            XCTAssert(
                matches(lhs: expect, rhs: actual),
                "\(expect) != \(actual)",
                file: file,
                line: line
            )

            return actual
        }
    }

    func matches(lhs: NSDictionary, rhs: NSDictionary) -> Bool {
        func equals(lhs: Any?, rhs: Any?) -> Bool {
            switch (lhs, rhs) {
            case (.none, .none):
                return true
            case (.some, .none), (.none, .some):
                return false
            case let (.some(l as String), .some(r as String)):
                return l == "*" || r == "*" || l == r
            case let (.some(l as Double), .some(r as Double)):
                return l == r
            case let (.some(l as NSDictionary), .some(r as NSDictionary)):
                return matches(lhs: l, rhs: r)
            default:                                
                return false
            }
        }

        guard lhs.count == rhs.count else { return false }

        for key in lhs.allKeys {
            if !equals(lhs: lhs[key], rhs: rhs[key]) {
                return false
            }
        }

        return true
    }

    func event(
        type: String,
        id: String = "*",
        visitId: String? = nil,
        createdAtWithMilliseconds: Date? = nil,
        destination: String? = nil,
        data: NSDictionary = [:]
    ) -> NSDictionary {
        [
            "type": type,
            "id": id,
            "visitId": visitId ?? visitDetails?.visitId.uuidString ?? "*",
            "createdAtWithMilliseconds": createdAtWithMilliseconds ?? Date.provide().iso8601withFractionalSeconds,
            "destination": [
                "id": destination ?? connectionContext.destinationId.uuidString
            ],
            "data": data
        ] as NSDictionary
    }

    func visit() -> NSDictionary {
        event(type: "VisitorVisit", visitId: "*")
    }

    func pageView(title: String, url: String, visitId: String? = nil) -> NSDictionary {
        event(type: "PageView", visitId: visitId, data: ["title": title, "url": url])
    }
    
    func pageViewEnded(title: String, url: String, visitId: String? = nil) -> NSDictionary {
        event(type: "TimeSpentOnPage", visitId: visitId, data: [ "title": title, "url": url])
    }

    func chatWindowOpen() -> NSDictionary {
        event(type: "ChatWindowOpened")
    }

    func conversion(type: String, amount: Double) -> NSDictionary {
        event(
            type: "Conversion",
            data: [
                "conversionType": type,
                "conversionValue": amount,
                "conversionTimeWithMilliseconds": Date.provide().iso8601withFractionalSeconds
            ] as NSDictionary
        )
    }

    func proactiveAction(type: String, details: ProactiveActionDetails) -> NSDictionary {
        event(
            type: type,
            data: [
                "actionId": details.id.uuidString,
                "actionName": details.name,
                "actionType": details.type.rawValue
            ]
        )
    }

    func proactiveActionDisplayed(details: ProactiveActionDetails) -> NSDictionary {
        proactiveAction(type: "ProactiveActionDisplayed", details: details)
    }

    func proactiveActionClicked(details: ProactiveActionDetails) -> NSDictionary {
        proactiveAction(type: "ProactiveActionClicked", details: details)
    }

    func proactiveActionSuccess(details: ProactiveActionDetails) -> NSDictionary {
        proactiveAction(type: "ProactiveActionSuccess", details: details)
    }

    func proactiveActionFailure(details: ProactiveActionDetails) -> NSDictionary {
        proactiveAction(type: "ProactiveActionFailed", details: details)
    }
}
