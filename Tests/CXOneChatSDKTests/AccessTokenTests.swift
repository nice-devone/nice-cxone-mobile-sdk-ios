import XCTest
@testable import CXoneChatSDK


class AccessTokenTests: XCTestCase {
    
    // MARK: - Properties
    
    var sut: AccessTokenDTO!
    
    
    // MARK: - Lifecycle
    
    override func setUpWithError() throws {
        sut = AccessTokenDTO(token: "token", expiresIn: 180)
    }

    override func tearDownWithError() throws {
        sut = nil
    }

    
    // MARK: - Tests
    
    func testAccessTokenIsnotExpired() {
        XCTAssertFalse(sut.isExpired)
    }

    func testAccessTokenIsExpired() {
        sut = AccessTokenDTO(token: "token", expiresIn: 1)
        
        if #available(iOS 15, *) {
            RunLoop.main.run(until: Date.now + 3)
            XCTAssertTrue(self.sut.isExpired)
        } else {
            XCTFail("\(#function) failed")
        }
    }

}
