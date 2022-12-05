import KeychainSwift
import XCTest
@testable import CXoneChatSDK


class CustomerProviderTests: CXoneXCTestCase {
    
    // MARK: - Properties
    
    // swiftlint:disable:next force_cast
    private lazy var customerProvider = CXoneChat.customer as! CustomerService
    
    
    // MARK: - Tests
    
    func testNilUser() {
        XCTAssertNil(CXoneChat.customer.get())
    }
    
    func testSetUser() {
        CXoneChat.customer.set(.init(id: UUID().uuidString, firstName: "John", lastName: "Doe"))
        
        XCTAssertNotNil(CXoneChat.customer.get())
    }
    
    func testEmptyDeviceToken() {
        XCTAssertEqual(customerProvider.connectionContext.deviceToken, "")
    }
    
    func testSetStringDeviceToken() {
        CXoneChat.customer.setDeviceToken("device_token")
        
        XCTAssertEqual(customerProvider.connectionContext.deviceToken, "device_token")
    }
    
    func testSetDataDeviceToken() throws {
        guard let data = "device_token".data(using: .utf8) else {
            throw CXoneChatError.missingParameter("data")
        }
        
        CXoneChat.customer.setDeviceToken(data)
        
        XCTAssertEqual(customerProvider.connectionContext.deviceToken, "6465766963655f746f6b656e")
    }
    
    func testEmptyAuthCode() {
        XCTAssertEqual(customerProvider.connectionContext.authorizationCode, "")
    }
    
    func testSetAuthCode() {
        CXoneChat.customer.setAuthorizationCode("auth_code")
        
        XCTAssertEqual(customerProvider.connectionContext.authorizationCode, "auth_code")
    }
    
    func testEmptyCodeVerifier() {
        XCTAssertEqual(customerProvider.connectionContext.codeVerifier, "")
    }
    
    func testSetCodeVerifier() {
        CXoneChat.customer.setCodeVerifier("verifier")
        
        XCTAssertEqual(customerProvider.connectionContext.codeVerifier, "verifier")
    }
    
    func testSetCustomerNameForEmptyCustomer() {
        CXoneChat.customer.setName(firstName: "John", lastName: "Doe")
        
        XCTAssertNotNil(CXoneChat.customer.get())
        XCTAssertEqual(CXoneChat.customer.get()?.firstName, "John")
        XCTAssertEqual(CXoneChat.customer.get()?.lastName, "Doe")
    }
    
    func testUpdateCustomerName() {
        CXoneChat.customer.set(.init(id: UUID().uuidString, firstName: "John", lastName: "Doe"))
        
        CXoneChat.customer.setName(firstName: "Peter", lastName: "Parker")
        
        XCTAssertNotNil(CXoneChat.customer.get())
        XCTAssertEqual(CXoneChat.customer.get()?.firstName, "Peter")
        XCTAssertEqual(CXoneChat.customer.get()?.lastName, "Parker")
    }
}
