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

import XCTest
@testable import CXoneChatSDK

class AccessTokenTests: XCTestCase {
    
    // MARK: - Properties
    
    let dateProvider = DateProviderMock()
    
    var sut: AccessTokenDTO?
    
    // MARK: - Lifecycle
    
    override func setUpWithError() throws {
        sut = AccessTokenDTO(token: "token", expiresIn: 180, currentDate: dateProvider.now)
    }

    override func tearDownWithError() throws {
        sut = nil
    }

    // MARK: - Tests
    
    func testAccessTokenIsnotExpired() {
        XCTAssertFalse(sut?.isExpired(currentDate: dateProvider.now) ?? true)
    }

    func testAccessTokenIsExpired() {
        sut = AccessTokenDTO(token: "token", expiresIn: 1, currentDate: dateProvider.now)
        
        RunLoop.main.run(until: Date() + 3)
        XCTAssertTrue(sut?.isExpired(currentDate: dateProvider.now) ?? false)
    }
}
