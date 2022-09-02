//
//  ISOStringTest.swift
//  
//
//  Created by kjoe on 8/2/22.
//

import XCTest
@testable import CXOneChatSDK
class ISOStringTest: XCTestCase {

    func testDateFromIsoStringNotNil() {
        let stringDate = "2022-03-15T11:54:51.600Z"
        XCTAssertNotNil(stringDate.iso8601withFractionalSeconds)
    }
    func testDateFromInvalidStringReturnNil() {
        let string = "2022/254-56"
        XCTAssertNil(string.iso8601withFractionalSeconds)
    }
    func testDatefromEmptyStringIsNil() {
        let string = ""
        XCTAssertNil(string.iso8601withFractionalSeconds)
    }

}
