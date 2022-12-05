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
