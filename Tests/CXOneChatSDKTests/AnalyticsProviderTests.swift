@testable import CXoneChatSDK
import XCTest


class AnalyticsProviderTests: CXoneXCTestCase {
    
    // MARK: - Lifecycle
    
    override func setUp() async throws {
        try await super.setUp()
        
        try await setUpConnection()
    }
    
    
    // MARK: - Tests
    
    func testEmptyVisitorId() async throws {
        CXoneChat.connection.disconnect()
        (CXoneChat.analytics as? AnalyticsService)?.visitorId = nil
        
        XCTAssertNil(CXoneChat.analytics.visitorId)
        
        try await setUpConnection()
        
        XCTAssertNotNil(CXoneChat.analytics.visitorId)
    }
    
    func testSetVisitorId() {
        (CXoneChat.analytics as? AnalyticsService)?.visitorId = UUID()
        
        XCTAssertNotNil(CXoneChat.analytics.visitorId)
    }
    
    func testViewPageThrows() {
        CXoneChat.connection.disconnect()
        
        XCTAssertThrowsError(try CXoneChat.analytics.viewPage(title: "page", uri: "uri"))
    }
    
    func testViewPageNoThrow() {
        XCTAssertNoThrow(try CXoneChat.analytics.viewPage(title: "page", uri: "uri"))
    }
    
    func testChatWindowOpenThrows() {
        CXoneChat.connection.disconnect()
        
        XCTAssertThrowsError(try CXoneChat.analytics.chatWindowOpen())
    }
    
    func testChatWindowOpenNoThrow() {
        XCTAssertNoThrow(try CXoneChat.analytics.chatWindowOpen())
    }
    
    func testVisitThrowsNotConnected() {
        CXoneChat.connection.disconnect()
        
        XCTAssertThrowsError(try CXoneChat.analytics.visit())
    }
    
    func testVisitThrowsMissingVisitorId() {
        socketService.connectionContext.visitorId = nil
        
        XCTAssertThrowsError(try CXoneChat.analytics.visit())
    }
    
    func testVisitThrowsNoThrow() {
        XCTAssertNoThrow(try CXoneChat.analytics.visit())
    }
    
    func testConversionThrows() {
        CXoneChat.connection.disconnect()
        
        XCTAssertThrowsError(try CXoneChat.analytics.conversion(type: "type", value: .pi))
    }
    
    func testConversionNoThrow() {
        XCTAssertNoThrow(try CXoneChat.analytics.conversion(type: "type", value: .pi))
    }
    
    func testCustomVisitorEventThrows() {
        CXoneChat.connection.disconnect()
        
        XCTAssertThrowsError(try CXoneChat.analytics.customVisitorEvent(data: .custom("data")))
    }
    
    func testCustomVisitorEventNoThrow() {
        XCTAssertNoThrow(try CXoneChat.analytics.customVisitorEvent(data: .custom("data")))
    }
    
    func testProactiveActionDisplayThrows() {
        CXoneChat.connection.disconnect()
        
        XCTAssertThrowsError(
            try CXoneChat.analytics.proactiveActionDisplay(data: .init(id: UUID(), name: "", type: .welcomeMessage, content: nil))
        )
    }
    
    func testProactiveActionDisplayNoThrow() {
        XCTAssertNoThrow(
            try CXoneChat.analytics.proactiveActionDisplay(data: .init(id: UUID(), name: "", type: .welcomeMessage, content: nil))
        )
    }
    
    func testProactiveActionClickThrows() {
        CXoneChat.connection.disconnect()
        
        XCTAssertThrowsError(
            try CXoneChat.analytics.proactiveActionClick(data: .init(id: UUID(), name: "", type: .welcomeMessage, content: nil))
        )
    }
    
    func testProactiveActionClickNoThrow() {
        XCTAssertNoThrow(
            try CXoneChat.analytics.proactiveActionClick(data: .init(id: UUID(), name: "", type: .welcomeMessage, content: nil)
            )
        )
    }
    
    func testProactiveActionSuccessThrows() {
        CXoneChat.connection.disconnect()
        
        XCTAssertThrowsError(
            try CXoneChat.analytics.proactiveActionSuccess(true, data: .init(id: UUID(), name: "", type: .welcomeMessage, content: nil))
        )
    }
    
    func testProactiveActionSuccessNoThrow() {
        XCTAssertNoThrow(
            try CXoneChat.analytics.proactiveActionSuccess(true, data: .init(id: UUID(), name: "", type: .welcomeMessage, content: nil))
        )
    }
    
    func testProactiveActionFailureThrows() {
        CXoneChat.connection.disconnect()
        
        XCTAssertThrowsError(
            try CXoneChat.analytics.proactiveActionSuccess(false, data: .init(id: UUID(), name: "", type: .welcomeMessage, content: nil))
        )
    }
    
    func testProactiveActionFailureNoThrow() {
        XCTAssertNoThrow(
            try CXoneChat.analytics.proactiveActionSuccess(false, data: .init(id: UUID(), name: "", type: .welcomeMessage, content: nil))
        )
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
    
    func testCustomVisitorEventEntityMapperMapsCorretly() {
        let data = ProactiveActionDetailsMapper.map(
            .init(id: UUID(), name: "actionName", type: .welcomeMessage, content: .init(bodyText: "bodyText"))
        )
        
        XCTAssertTrue(data.actionName == "actionName")
        XCTAssertTrue(data.actionType == .welcomeMessage)
        XCTAssertTrue(data.data?.content.bodyText == "bodyText")
    }
}
