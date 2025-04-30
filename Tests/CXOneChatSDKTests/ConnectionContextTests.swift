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

class ConnectionContextTests: XCTestCase {

    // MARK: - Properties
    
    private let dateProvider = DateProviderMock()
    
    var sut = ConnectionContextImpl(keychainService: KeychainServiceMock(), session: .shared)
    
    // MARK: - Tests
    
    override func setUp() {
        sut.clear()
    }
    
    func testVisitorDetailsSetProperly() {
        XCTAssertNil(sut.visitDetails)
        
        sut.visitDetails = CurrentVisitDetails(visitId: UUID(), expires: Date())
        
        XCTAssertNotNil(sut.visitDetails)
    }
    
    func testVisitorIdSetProperly() {
        XCTAssertNil(sut.visitorId)
        sut.visitorId = UUID()
        XCTAssertNotNil(sut.visitorId)
    }
    
    func testCustomerSetProperly() {
        XCTAssertNil(sut.customer)
        sut.customer = CustomerIdentityDTO(idOnExternalPlatform: UUID().uuidString, firstName: "John", lastName: "Doe")
        XCTAssertNotNil(sut.customer)
    }
    
    func testAccessTokenSetProperly() {
        XCTAssertNil(sut.accessToken)
        
        sut.accessToken = AccessTokenDTO(token: "data", expiresIn: .max, currentDate: dateProvider.now)
        
        XCTAssertNotNil(sut.accessToken)
    }
    
    func testPrechatSurveyMapCorrectly() throws {
        let data = try loadBundleData(from: "ChannelConfiguration", type: "json")
        let configuration = try JSONDecoder().decode(ChannelConfigurationDTO.self, from: data)
        
        XCTAssertEqual(configuration.prechatSurvey?.customFields.count, 4)
        XCTAssertEqual(configuration.prechatSurvey?.name, "Precontact Survey form")
        
        configuration.prechatSurvey?.customFields.forEach { customField in
            switch customField.type {
            case .textField(let entity):
                if entity.isEmail {
                    XCTAssertEqual(entity.ident, "email")
                    XCTAssertEqual(entity.label, "E-mail")
                    XCTAssertTrue(customField.isRequired)
                } else {
                    XCTAssertEqual(entity.ident, "age")
                    XCTAssertEqual(entity.label, "Age")
                    XCTAssertFalse(customField.isRequired)
                }
            case .selector(let entity):
                XCTAssertFalse(customField.isRequired)
                XCTAssertEqual(entity.ident, "gender")
                XCTAssertEqual(entity.label, "Gender")
                XCTAssertEqual(entity.options.count, 3)
            case .hierarchical(let entity):
                XCTAssertTrue(customField.isRequired)
                XCTAssertEqual(entity.ident, "broken_device")
                XCTAssertEqual(entity.label, "Broken Device")
                XCTAssertEqual(entity.nodes.count, 2)
            }
        }
        
        XCTAssertFalse(configuration.liveChatAvailability.isChannelLiveChat)
    }
    
    func testLiveChatAvailabilityMapCorrectly() throws {
        let data = try loadBundleData(from: "ChannelConfiguration", type: "json")
        let configuration = try JSONDecoder().decode(ChannelConfigurationDTO.self, from: data)
        
        XCTAssertFalse(configuration.liveChatAvailability.isChannelLiveChat)
        XCTAssertFalse(configuration.liveChatAvailability.isOnline)
    }
}
