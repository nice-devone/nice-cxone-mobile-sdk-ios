@testable import CXoneChatSDK
import XCTest


class CXoneChatTests: XCTestCase {
    
    // MARK: - Properties
    
    private var currentExpectation = XCTestExpectation(description: "")
    
    
    // MARK: - Lifecycle
    
    override func tearDownWithError() throws {
        (CXoneChat.shared as? CXoneChat)?.connection.disconnect()
    }
    
    
    // MARK: - Tests
    
    func testSingletonDelegateSet() {
        XCTAssertNotNil(((CXoneChat.shared as? CXoneChat)?.connection as? ConnectionService)?.socketService.delegate)
    }
    
    func testSignOutResetProperly() {
        (CXoneChat.shared.threads as? ChatThreadsService)?.threads.append(.init(id: UUID()))
        XCTAssertFalse(CXoneChat.shared.threads.get().isEmpty)
        
        CXoneChat.signOut()
        
        XCTAssertTrue(CXoneChat.shared.threads.get().isEmpty)
    }
    
    func testConfigureLoggerProperly() {
        CXoneChat.configureLogger(level: .trace, verbosity: .simple)
        
        XCTAssertTrue(LogManager.verbository == .simple)
        XCTAssertTrue(LogManager.level == .trace)
    }
    
    func testLoggerDelegateCalled() {
        currentExpectation = XCTestExpectation(description: "testLoadThreadDataNoThrow")
        currentExpectation.expectedFulfillmentCount = 4
        
        CXoneChat.shared.logDelegate = self
        
        LogManager.error("")
        LogManager.warning("")
        LogManager.info("")
        LogManager.trace("")
        
        
        wait(for: [currentExpectation], timeout: 1.0)
    }
}


// MARK: - LogDelegate

extension CXoneChatTests: LogDelegate {
    
    func logError(_ message: String) {
        currentExpectation.fulfill()
    }
    
    func logWarning(_ message: String) {
        currentExpectation.fulfill()
    }
    
    func logInfo(_ message: String) {
        currentExpectation.fulfill()
    }
    
    func logTrace(_ message: String) {
        currentExpectation.fulfill()
    }
    
    
}
