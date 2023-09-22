import XCTest
@testable import CXoneChatSDK

class CustomerIdentityTests: XCTestCase {

    func testCustomeridentityFullNameEmpty() {
        let customr = CustomerIdentity(id: UUID().uuidString, firstName: nil, lastName: nil)
        
        XCTAssertEqual(customr.fullName, " ")
    }

}
