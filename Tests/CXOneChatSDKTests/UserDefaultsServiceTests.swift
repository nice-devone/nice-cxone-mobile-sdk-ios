//
// Copyright (c) 2021-2025. NICE Ltd. All rights reserved.
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

@testable import CXoneChatSDK
import XCTest

class UserDefaultsServiceTests: XCTestCase {
    
    // MARK: - Properties
    
    private let sut = UserDefaultsService.shared
    
    // MARK: - Lifecycle
    
    override class func tearDown() {
        super.tearDown()
        
        UserDefaultsService.purge()
    }
    
    // MARK: - Tests
    
    func testRawStringStoredCorrectly() {
        sut.set("data", for: "key")
        
        XCTAssertEqual(sut.get(String.self, for: "key"), "data", "Storage is not set properly - value for key is not set")
    }
    
    func testPurgeWorksCorrectly() {
        sut.set("foo", for: "key")
        
        XCTAssertNotNil(sut.get(String.self, for: "key"), "Value is not properly storing in the UserDefaults storage")
        
        UserDefaultsService.purge()
        
        XCTAssertNil(sut.get(String.self, for: "key"), "UserDefaults Storage is not properly purged")
    }
    
    func testRemoveCustomKeyWorksCorrectly() {
        sut.set("foo", for: "key")
        
        XCTAssertNotNil(sut.get(String.self, for: "key"), "Value is not properly storing in the UserDefaults storage")
        
        sut.remove("key")
        
        XCTAssertNil(sut.get(String.self, for: "key"), "UserDefaults Storage is not properly purged")
    }
    
    func testRemoveDefinedKeyWorksCorrectly() {
        sut.set("foo", for: .welcomeMessage)
        XCTAssertNotNil(sut.get(String.self, for: .welcomeMessage), "Value is not properly storing in the UserDefaults storage")
        
        sut.remove(.welcomeMessage)
        
        XCTAssertNil(sut.get(String.self, for: .welcomeMessage), "UserDefaults Storage is not properly purged")
    }
}
