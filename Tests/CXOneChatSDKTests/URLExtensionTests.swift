//
//  URLExtensionTests.swift
//  
//
//  Created by David Berry on 1/12/24.
//

import XCTest
@testable import CXoneChatSDK

final class URLExtensionTests: XCTestCase {
    func testAppendPath() {
        let url = URL(string: "http://base.com/root") / "a/b"
        XCTAssertEqual("http://base.com/root/a/b", url?.absoluteString)
    }

    func testAppendPathEscapes() {
        let url = URL(string: "http://base.com/root") / "a/b 1"
        XCTAssertEqual("http://base.com/root/a/b%201", url?.absoluteString)
    }

    func testAppendSimpleQuery() {
        let url = URL(string: "http://base.com/root") & ("a", "1")
        XCTAssertEqual("http://base.com/root?a=1", url?.absoluteString)
    }

    func testAppendSimpleQueryEscapes() {
        let url = URL(string: "http://base.com/root") & ("a", "the end")
        XCTAssertEqual("http://base.com/root?a=the%20end", url?.absoluteString)
    }

    func testAppendSimpleQueryNoValue() {
        let url = URL(string: "http://base.com/root") & ("a", nil)
        XCTAssertEqual("http://base.com/root?a", url?.absoluteString)
    }

    func testAppendMultipleQuery() {
        let url = URL(string: "http://base.com/root") & [("a", "1"), ("b", "2")]
        XCTAssertEqual("http://base.com/root?a=1&b=2", url?.absoluteString)
    }
}
