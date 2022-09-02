//
//  AccessTokenTest.swift
//  
//
//  Created by kjoe on 8/17/22.
//

import XCTest
@testable import CXOneChatSDK
class AccessTokenTest: XCTestCase {
    var sut: AccessToken!
    override func setUpWithError() throws {
        sut = AccessToken(token: "token", expiresIn: 180)
    }

    override func tearDownWithError() throws {
        sut = nil
    }

    func testAccessTokenIsnotExpired() {
        XCTAssertFalse(sut.isExpired)
    }

    func testAccessTokenIsExpired() {
        sut = AccessToken(token: "token", expiresIn: 1)
        if #available(iOS 15, *) {
            RunLoop.main.run(until: Date.now + 3)
            XCTAssertTrue(self.sut.isExpired)
        } else {
            XCTFail()
        }
    }

}
