//
//  CustomerIdentityTest.swift
//  
//
//  Created by kjoe on 8/2/22.
//

import XCTest
@testable import CXOneChatSDK

class CustomerIdentityTest: XCTestCase {

    func testCustomeridentityFullNameEmpty() {
        let customr = CustomerIdentity(idOnExternalPlatform: UUID().uuidString)
        XCTAssertEqual(customr.fullName, " ")
    }

}
