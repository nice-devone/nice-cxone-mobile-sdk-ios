import XCTest
@testable import CXoneChatSDK


class ConnectionContextTests: XCTestCase {

    // MARK: - Properties
    
    var sut = ConnectionContextImpl(keychainSwift: KeychainSwiftMock(), session: .shared)
    
    
    // MARK: - tests
    
    func testNotConnected() throws {
        XCTAssertFalse(sut.isConnected)
        
        sut.channelId = "channel_id"
        XCTAssertFalse(sut.isConnected)
        
        sut.brandId = 1234
        XCTAssertFalse(sut.isConnected)
        
        sut.visitorId = UUID()
        XCTAssertFalse(sut.isConnected)
        
        sut.customer = .init(idOnExternalPlatform: UUID().uuidString, firstName: "John", lastName: "Doe")
        XCTAssertTrue(sut.isConnected)
    }
    
    func testVisitorIdSetProperly() {
        XCTAssertNil(sut.visitorId)
        sut.visitorId = UUID()
        XCTAssertNotNil(sut.visitorId)
    }
    
    func testCustomerSetProperly() {
        XCTAssertNil(sut.customer)
        sut.customer = .init(idOnExternalPlatform: UUID().uuidString, firstName: "John", lastName: "Doe")
        XCTAssertNotNil(sut.customer)
    }
    
    func testAccessTokenSetProperly() {
        XCTAssertNil(sut.accessToken)
        
        XCTAssertNoThrow(try sut.setAccessToken(.init(token: "data", expiresIn: .max)))
        XCTAssertNotNil(sut.accessToken)
    }
    
}
