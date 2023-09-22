import XCTest
@testable import CXoneChatSDK

class AccessTokenTests: XCTestCase {
    
    // MARK: - Properties
    
    let dateProvider = DateProviderMock()
    
    var sut: AccessTokenDTO?
    
    // MARK: - Lifecycle
    
    override func setUpWithError() throws {
        sut = AccessTokenDTO(token: "token", expiresIn: 180)
    }

    override func tearDownWithError() throws {
        sut = nil
    }

    // MARK: - Tests
    
    func testAccessTokenIsnotExpired() {
        XCTAssertFalse(sut?.isExpired(currentDate: dateProvider.now) ?? true)
    }

    func testAccessTokenIsExpired() throws {
        sut = AccessTokenDTO(token: "token", expiresIn: 1)
        
        RunLoop.main.run(until: Date() + 3)
        XCTAssertTrue(sut?.isExpired(currentDate: dateProvider.now) ?? false)
    }
}
