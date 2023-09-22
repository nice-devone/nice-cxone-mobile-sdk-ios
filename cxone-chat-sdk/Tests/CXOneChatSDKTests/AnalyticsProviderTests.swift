@testable import CXoneChatSDK
import XCTest

class AnalyticsProviderTests: CXoneXCTestCase {

    // MARK: - Properties

    var connectionService: ConnectionService? {
        CXoneChat.connection as? ConnectionService
    }

    var analyticsService: AnalyticsService? {
        CXoneChat.analytics as? AnalyticsService
    }

    var connectionContext: ConnectionContextMock? {
        analyticsService?.connectionContext as? ConnectionContextMock
    }

    var visitDetails: CurrentVisitDetails? {
        get { connectionContext?.visitDetails }
        set { connectionContext?.visitDetails = newValue }
    }

    lazy var isoFormatter = ISO8601DateFormatter()

    lazy var proactiveDetails = ProactiveActionDetails(id: UUID(), name: "", type: .welcomeMessage, content: nil)

    var now: Date { dateProvider.now }

    // MARK: - Lifecycle

    override func setUp() async throws {
        continueAfterFailure = false

        try await super.setUp()

        try await setUpConnection()
    }

    // MARK: - Tests
    
    func testEmptyVisitorId() async throws {
        CXoneChat.connection.disconnect()
        (CXoneChat.analytics as? AnalyticsService)?.visitorId = nil
        
        XCTAssertNil(analyticsService?.visitorId)
        
        try await setUpConnection()
        
        XCTAssertNotNil(analyticsService?.visitorId)
    }
    
    func testSetVisitorId() {
        analyticsService?.visitorId = UUID()
        
        XCTAssertNotNil(analyticsService?.visitorId)
    }

    func testViewPageNoConnectionThrows() async throws {
        CXoneChat.connection.disconnect()
        
        do {
            try await analyticsService?.viewPage(title: "page", url: "url")
            
            throw XCTError("Should throw an error")
        } catch {
            return
        }
    }

    func testViewPageNoVisitCreatesVisit() async throws {
        visitDetails = nil

        let events = try await verify(sends: visit(), pageView(title: "page", url: "url")) {
            try await analyticsService?.viewPage(title: "page", url: "url")
        }
        
        XCTAssertNotNil(visitDetails)

        XCTAssertEqual(visitDetails?.visitId.uuidString, events[0]["visitId"] as? String)
        XCTAssertEqual(visitDetails?.visitId.uuidString, events[1]["visitId"] as? String)

        XCTAssertEqual(Date(timeInterval: 30 * 60, since: now), visitDetails?.expires)
    }

    func testViewPageStaleVisitCreatesVisit() async throws {
        let oldUUID = UUID()
        visitDetails = CurrentVisitDetails(visitId: oldUUID, expires: Date(timeInterval: -1, since: now))

        try await verify(sends: visit(), pageView(title: "page", url: "url", visitId: "*")) {
            try await analyticsService?.viewPage(title: "page", url: "url")
        }

        XCTAssertNotNil(visitDetails)
        XCTAssertEqual(Date(timeInterval: 30 * 60, since: now), visitDetails?.expires)
        XCTAssertNotEqual(oldUUID, visitDetails?.visitId)
    }

    func testViewPageCurrentVisitJustUpdatesExpires() async throws {
        let oldUUID = UUID()
        visitDetails = CurrentVisitDetails(visitId: oldUUID, expires: Date(timeInterval: 1, since: now))

        try await verify(sends: pageView(title: "page", url: "url")) {
            try await analyticsService?.viewPage(title: "page", url: "url")
        }

        XCTAssertNotNil(visitDetails)
        XCTAssertEqual(Date(timeInterval: 30 * 60, since: now), visitDetails?.expires)
        XCTAssertEqual(oldUUID, visitDetails?.visitId)
    }
    
    func testViewPageEndedNoConnectionThrows() async throws {
        CXoneChat.connection.disconnect()
        
        analyticsService?.lastPageViewed = PageViewEventDTO(title: "page", url: "url", timestamp: dateProvider.now.addingTimeInterval(-100))
        
        do {
            try await analyticsService?.viewPageEnded(title: "page", url: "url")
            
            throw XCTError("Should throw an error")
        } catch {
            return
        }
    }

    func testViewPageEndedStaleVisitCreatesVisit() async throws {
        let oldUUID = UUID()
        visitDetails = CurrentVisitDetails(visitId: oldUUID, expires: Date(timeInterval: -1, since: now))

        try await verify(sends: visit(), pageView(title: "page", url: "url", visitId: "*")) {
            try await analyticsService?.viewPage(title: "page", url: "url")
        }

        XCTAssertNotNil(visitDetails)
        XCTAssertEqual(Date(timeInterval: 30 * 60, since: now), visitDetails?.expires)
        XCTAssertNotEqual(oldUUID, visitDetails?.visitId)
    }

    func testChatWindowOpenDisconnectedThrows() async throws {
        visitDetails = CurrentVisitDetails(visitId: UUID(), expires: Date(timeInterval: 1, since: now))
        
        CXoneChat.connection.disconnect()
        
        do {
            try await analyticsService?.chatWindowOpen()
            
            throw XCTError("Should throw an error")
        } catch {
            return
        }
    }

    func testChatWindowOpenOutOfSequenceThrows() async throws {
        do {
            try await analyticsService?.chatWindowOpen()
            
            throw XCTError("Should throw an error")
        } catch {
            return
        }
    }

    func testChatWindowOpen() async throws {
        visitDetails = CurrentVisitDetails(visitId: UUID(), expires: Date(timeInterval: 1, since: now))

        try await verify(sends: chatWindowOpen()) {
            try await analyticsService?.chatWindowOpen()
        }
    }

    func testConversionDisconnectedThrows() async throws {
        visitDetails = CurrentVisitDetails(visitId: UUID(), expires: Date(timeInterval: 1, since: now))
        
        CXoneChat.connection.disconnect()

        do {
            try await analyticsService?.conversion(type: "sale", value: 98)
            
            throw XCTError("Should throw an error")
        } catch {
            return
        }
    }

    func testConversionOutOfSequenceThrows() async throws {
        do {
            try await analyticsService?.conversion(type: "sale", value: 98)
            
            throw XCTError("Should throw an error")
        } catch {
            return
        }
    }

    func testConversion() async throws {
        visitDetails = CurrentVisitDetails(visitId: UUID(), expires: Date(timeInterval: 1, since: now))

        try await verify(sends: conversion(type: "sale", amount: 98)) {
            try await analyticsService?.conversion(type: "sale", value: 98)
        }
    }

    func testCustomVisitorEventThrows() {
        CXoneChat.connection.disconnect()
        
        XCTAssertThrowsError(try analyticsService?.customVisitorEvent(data: .custom("data")))
    }
    
    func testCustomVisitorEventNoThrow() {
        XCTAssertNoThrow(try analyticsService?.customVisitorEvent(data: .custom("data")))
    }
    
    func testProactiveActionDisplayDisconnectedThrows() async throws {
        visitDetails = CurrentVisitDetails(visitId: UUID(), expires: Date(timeInterval: 1, since: now))
       
        CXoneChat.connection.disconnect()

        do {
            try await analyticsService?.proactiveActionDisplay(data: proactiveDetails)
            
            throw XCTError("Should throw an error")
        } catch {
            return
        }
    }

    func testProactiveActionDisplayOutOfSequenceThrows() async throws {
        do {
            try await analyticsService?.proactiveActionDisplay(data: proactiveDetails)
            
            throw XCTError("Should throw an error")
        } catch {
            return
        }
    }

    func testProactiveActionDisplay() async throws {
        visitDetails = CurrentVisitDetails(visitId: UUID(), expires: Date(timeInterval: 1, since: now))

        try await verify(sends: proactiveActionDisplayed(details: proactiveDetails)) {
            try await analyticsService?.proactiveActionDisplay(data: proactiveDetails)
        }
    }
    
    func testProactiveActionClickedDisconnectedThrows() async throws {
        visitDetails = CurrentVisitDetails(visitId: UUID(), expires: Date(timeInterval: 1, since: now))
       
        CXoneChat.connection.disconnect()

        do {
            try await analyticsService?.proactiveActionClick(data: proactiveDetails)
            
            throw XCTError("Should throw an error")
        } catch {
            return
        }
    }

    func testProactiveActionClickedOutOfSequenceThrows() async throws {
        do {
            try await analyticsService?.proactiveActionClick(data: proactiveDetails)
            
            throw XCTError("Should throw an error")
        } catch {
            return
        }
    }

    func testProactiveActionClicked() async throws {
        visitDetails = CurrentVisitDetails(visitId: UUID(), expires: Date(timeInterval: 1, since: now))

        try await verify(sends: proactiveActionClicked(details: proactiveDetails)) {
            try await analyticsService?.proactiveActionClick(data: proactiveDetails)
        }
    }

    func testProactiveActionSuccessDisconnectedThrows() async throws {
        visitDetails = CurrentVisitDetails(visitId: UUID(), expires: Date(timeInterval: 1, since: now))
       
        CXoneChat.connection.disconnect()

        do {
            try await analyticsService?.proactiveActionSuccess(true, data: proactiveDetails)
            
            throw XCTError("Should throw an error")
        } catch {
            return
        }
    }

    func testProactiveActionSuccessOutOfSequenceThrows() async throws {
        do {
            try await analyticsService?.proactiveActionSuccess(true, data: proactiveDetails)
            
            throw XCTError("Should throw an error")
        } catch {
            return
        }
    }

    func testProactiveActionSuccess() async throws {
        visitDetails = CurrentVisitDetails(visitId: UUID(), expires: Date(timeInterval: 1, since: now))

        try await verify(sends: proactiveActionSuccess(details: proactiveDetails)) {
            try await analyticsService?.proactiveActionSuccess(true, data: proactiveDetails)
        }
    }

    func testProactiveActionFailureDisconnectedThrows() async throws {
        visitDetails = CurrentVisitDetails(visitId: UUID(), expires: Date(timeInterval: 1, since: now))
       
        CXoneChat.connection.disconnect()

        do {
            try await analyticsService?.proactiveActionSuccess(false, data: proactiveDetails)
            
            throw XCTError("Should throw an error")
        } catch {
            return
        }
    }

    func testProactiveActionFailureOutOfSequenceThrows() async throws {
        do {
            try await analyticsService?.proactiveActionSuccess(false, data: proactiveDetails)
            
            throw XCTError("Should throw an error")
        } catch {
            return
        }
    }

    func testProactiveActionFailure() async throws {
        visitDetails = CurrentVisitDetails(visitId: UUID(), expires: Date(timeInterval: 1, since: now))

        try await verify(sends: proactiveActionFailure(details: proactiveDetails)) {
            try await analyticsService?.proactiveActionSuccess(false, data: proactiveDetails)
        }
    }

    func testProactiveActionFailureThrows() async throws {
        CXoneChat.connection.disconnect()
        
        do {
            try await analyticsService?.proactiveActionSuccess(false, data: ProactiveActionDetails(id: UUID(), name: "", type: .welcomeMessage, content: nil))
            
            throw XCTError("Should throw an error")
        } catch {
            return
        }
    }
    
    func testTypingStartStartThrows() {
        CXoneChat.connection.disconnect()
        
        let thread = ChatThread(id: UUID())
        
        XCTAssertThrowsError(try CXoneChat.threads.reportTypingStart(true, in: thread))
    }
    
    func testTypingStartStartNoThrow() {
        let thread = ChatThread(id: UUID())
        
        XCTAssertNoThrow(try CXoneChat.threads.reportTypingStart(true, in: thread))
    }
    
    func testTypingStartEndThrows() {
        CXoneChat.connection.disconnect()
        
        let thread = ChatThread(id: UUID())
        
        XCTAssertThrowsError(try CXoneChat.threads.reportTypingStart(false, in: thread))
    }
    
    func testTypingStartEndNoThrow() {
        let thread = ChatThread(id: UUID())
        
        XCTAssertNoThrow(try CXoneChat.threads.reportTypingStart(false, in: thread))
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

            await waitForExpectations(timeout: 10.0)
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
            default:                                return false
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
            "createdAtWithMilliseconds": isoFormatter.string(from: createdAtWithMilliseconds ?? now),
            "destination": [
                "id": destination ?? connectionContext!.destinationId.uuidString
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
                "conversionTimeWithMilliseconds": isoFormatter.string(from: now)
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
