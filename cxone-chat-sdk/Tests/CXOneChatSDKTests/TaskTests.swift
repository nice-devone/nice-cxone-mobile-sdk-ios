import XCTest
@testable import CXoneChatSDK

final class TaskTests: XCTestCase {
    
    // MARK: - Properties
    
    private let attempts = 3
    private var callCount = 0
    
    // MARK: - Tests
    
    func testDelayedTaskRetriesSuccessfully() async throws {
        let result = try await Task.retrying(attempts: attempts) {
            try await self.delayedAsyncCall()
        }.value
        
        XCTAssertEqual(result, "Done")
    }
}

// MARK: - Private methods

private extension TaskTests {
    
    func delayedAsyncCall() async throws -> String {
        // Make the last call successful
        if callCount == attempts {
            return "Done"
        } else {
            callCount += 1
            
            throw CXoneChatError.serverError
        }
    }
}
