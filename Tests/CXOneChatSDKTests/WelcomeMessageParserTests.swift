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

class WelcomeMessageManagerTest: XCTestCase {

    // MARK: - Properties
    
    private let manager = {
        Date.provider = DateProviderMock()
        return WelcomeMessageManager()
    }()

    var sut = ""
    var expectation = ""
    
    // MARK: - Tests
    
    func testWelcomeMessageWithoutValueAndFallback() {
        sut = "Welcome {{customer.fullName}}!"
        expectation = "Welcome {{customer.fullName}}!"
        let customer = CustomerIdentityDTO(idOnExternalPlatform: UUID().uuidString, firstName: "", lastName: "")
        
        let parsedMessage = manager.parse(sut, contactFields: [], customerFields: [], customer: customer)
        
        XCTAssertEqual(expectation, parsedMessage, "Parsed message is not same as original one. Parsed message - \(parsedMessage)")
    }
    
    func testWelcomeMessageWithoutVariables() {
        sut = "Welcome stranger!"
        expectation = "Welcome stranger!"
        let customer = CustomerIdentityDTO(idOnExternalPlatform: UUID().uuidString, firstName: "John", lastName: "Doe")
        
        let parsedMessage = manager.parse(sut, contactFields: [], customerFields: [], customer: customer)
        
        XCTAssertEqual(expectation, parsedMessage, "Parsed message is not same as original one. Parsed message - \(parsedMessage)")
    }
    
    func testWelcomeMessageEmptyFallBack() {
        sut = "Welcome {{customer.firstName|}}!"
        expectation = "Welcome !"
        let customer = CustomerIdentityDTO(idOnExternalPlatform: UUID().uuidString, firstName: "", lastName: "")
        
        let parsedMessage = manager.parse(sut, contactFields: [], customerFields: [], customer: customer)
        
        XCTAssertEqual(expectation, parsedMessage, "Parsed message is not same as original one. Parsed message - \(parsedMessage)")
    }
    
    func testWelcomeMessageFallback() {
        sut = "Welcome {{customer.firstName|stranger}}!"
        expectation = "Welcome stranger!"
        let customer = CustomerIdentityDTO(idOnExternalPlatform: UUID().uuidString, firstName: "", lastName: "")
        
        let parsedMessage = manager.parse(sut, contactFields: [], customerFields: [], customer: customer)
        
        XCTAssertEqual(expectation, parsedMessage, "Parsed message is not same as original one. Parsed message - \(parsedMessage)")
    }
    
    func testWelcomeMessageFallbackCustomFieldsEmptyValue() {
        sut = "Welcome {{customer.firstName|stranger}}!"
        expectation = "Welcome stranger!"
        let customer = CustomerIdentityDTO(idOnExternalPlatform: UUID().uuidString, firstName: "", lastName: "")
        
        let parsedMessage = manager.parse(sut, contactFields: [], customerFields: [], customer: customer)
        
        XCTAssertEqual(expectation, parsedMessage, "Parsed message is not same as original one. Parsed message - \(parsedMessage)")
    }
    
    func testWelcomeMessageWithVariable() {
        sut = "Welcome {{customer.firstName|stranger}}!"
        expectation = "Welcome John!"
        let customer = CustomerIdentityDTO(idOnExternalPlatform: UUID().uuidString, firstName: "John", lastName: "Doe")
        
        let parsedMessage = manager.parse(sut, contactFields: [], customerFields: [], customer: customer)
        
        XCTAssertEqual(expectation, parsedMessage, "Parsed message is not same as original one. Parsed message - \(parsedMessage)")
    }
    
    func testWelcomeMessageFallWithVariable() {
        sut = "Welcome {{customer.firstName|stranger}}!"
        expectation = "Welcome stranger!"
        let customer = CustomerIdentityDTO(idOnExternalPlatform: UUID().uuidString, firstName: "", lastName: "")
        
        let parsedMessage = manager.parse(sut, contactFields: [], customerFields: [], customer: customer)
        
        XCTAssertEqual(expectation, parsedMessage, "Parsed message is not same as original one. Parsed message - \(parsedMessage)")
    }
    
    func testWelcomeMessageWithVariables() {
        sut = "Welcome {{customer.firstName}} {{customer.lastName}}!"
        expectation = "Welcome John Doe!"
        let customer = CustomerIdentityDTO(idOnExternalPlatform: UUID().uuidString, firstName: "John", lastName: "Doe")
        
        let parsedMessage = manager.parse(sut, contactFields: [], customerFields: [], customer: customer)
        
        XCTAssertEqual(expectation, parsedMessage, "Parsed message is not same as original one. Parsed message - \(parsedMessage)")
    }
    
    func testComplexWelcomeMessage() {
        sut = "Dear {{customer.firstName|customer}}, we would like to offer you a discount of {{customer.customFields.discount-value|5%}}."
        expectation = "Dear John, we would like to offer you a discount of 7.5%."
        let customer = CustomerIdentityDTO(idOnExternalPlatform: UUID().uuidString, firstName: "John", lastName: "Doe")
        let contactFields = [CustomFieldDTO(ident: "customer.customFields.discount-value", value: "7.5%", updatedAt: Date())]
        
        let parsedMessage = manager.parse(sut, contactFields: contactFields, customerFields: [], customer: customer)
        
        XCTAssertEqual(expectation, parsedMessage, "Parsed message is not same as original one. Parsed message - \(parsedMessage)")
    }
    
    func testWelcomeMessageComplexFallback() {
        sut = "Dear {{customer.firstName|customer}}, we would like to offer you a discount of {{customer.customFields.discountValue|5%}}."
        expectation = "Dear customer, we would like to offer you a discount of 5%."
        let customer = CustomerIdentityDTO(idOnExternalPlatform: UUID().uuidString, firstName: "", lastName: "")
        
        let parsedMessage = manager.parse(sut, contactFields: [], customerFields: [], customer: customer)
        
        XCTAssertEqual(expectation, parsedMessage, "Parsed message is not same as original one. Parsed message - \(parsedMessage)")
    }
    
    func testWelcomeMessageCombiningContactAndCustomerFields() {
        sut = "Dear {{customer.firstName|customer}}, we would like to offer you a discount of {{contact.customFields.discount_value|5%}}."
                + " Do you have {{customer.customFields.minutes|15 minutes}}?"
        expectation = "Dear John, we would like to offer you a discount of 2.5%. Do you have 10 minutes?"
        
        let customer = CustomerIdentityDTO(idOnExternalPlatform: UUID().uuidString, firstName: "John", lastName: "Doe")
        let customerFields = [CustomFieldDTO(ident: "contact.customFields.discount_value", value: "2.5%", updatedAt: Date())]
        let contactFields = [CustomFieldDTO(ident: "customer.customFields.minutes", value: "10 minutes", updatedAt: Date())]
        
        let parsedMessage = manager.parse(sut, contactFields: customerFields, customerFields: contactFields, customer: customer)
        
        XCTAssertEqual(expectation, parsedMessage, "Parsed message is not same as original one. Parsed message - \(parsedMessage)")
    }
    
    func testWelcomeMessageUnknownParametersFallbackMessage() {
        sut = "Dear {{customer.fullName}}, do you have 5 minutes to discuss your problem? {{fallbackMessage|Dear customer, can we discuss your problem?}}"
        expectation = "Dear customer, can we discuss your problem?"
        
        let customer = CustomerIdentityDTO(idOnExternalPlatform: UUID().uuidString, firstName: "", lastName: "")
        
        let parsedMessage = manager.parse(sut, contactFields: [], customerFields: [], customer: customer)
        
        XCTAssertEqual(expectation, parsedMessage, "Parsed message is not same as original one. Parsed message - \(parsedMessage)")
    }
}
