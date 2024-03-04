//
// Copyright (c) 2021-2023. NICE Ltd. All rights reserved.
//
// Licensed under the NICE License;
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//    https://github.com/nice-devone/nice-cxone-mobile-sdk-ios/blob/main/LICENSE
//
// TO THE EXTENT PERMITTED BY APPLICABLE LAW, THE CXONE MOBILE SDK IS PROVIDED ON
// AN “AS IS” BASIS. NICE HEREBY DISCLAIMS ALL WARRANTIES AND CONDITIONS, EXPRESS
// OR IMPLIED, INCLUDING (WITHOUT LIMITATION) WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE, NON-INFRINGEMENT, AND TITLE.
//

import XCTest
@testable import CXoneChatSDK

class StringExtensionsTests: XCTestCase {
    
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

    func testFormattedJSONNil() {
        XCTAssertNil("\"".formattedJSON)
    }
    
    func testFormattedJSONNotNil() {
        let json = "{\"key\": \"value\"}"
        
        XCTAssertNotNil(json.formattedJSON)
    }
    
    func testSubstringNil() {
        XCTAssertNil("".substring(from: "a"))
        XCTAssertNil("".substring(to: "a"))
    }
    
    func testSubstringNotNil() {
        XCTAssertNotNil("foo".substring(from: "f"))
        XCTAssertNotNil("foo".substring(to: "o"))
    }
    
    func testCompleteSubstringNil() {
        XCTAssertNil("".substring(from: "b", to: "r"))
        XCTAssertNil("b".substring(from: "b", to: "r"))
    }
    
    func testCompleteSubstringNotNil() {
        XCTAssertNotNil("bar".substring(from: "b", to: "r"))
    }
}
