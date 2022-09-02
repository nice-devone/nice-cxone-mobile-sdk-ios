//
//  AccesTokenTest.swift
//  
//
//  Created by kjoe on 8/2/22.
//

import XCTest
@testable import CXOneChatSDK
class AccesTokenPayloadTest: XCTestCase {

    func testInitWithNoNilText() {
        let text: String? = "tokenValue"
        XCTAssertNotNil(AccessTokenPayload(token: "token"))
        XCTAssertNotNil(AccessTokenPayload(token: text))
    }

}
