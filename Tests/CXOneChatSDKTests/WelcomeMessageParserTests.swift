import XCTest
@testable import CXoneChatSDK


class WelcomeMessageManagerTest: XCTestCase {

    // MARK: - Properties
    
    var sut = ""
    var expectation = ""
    
    
    // MARK: - Tests
    
    func testWelcomeMessageWithoutVariables() {
        sut = "Welcome stranger!"
        expectation = "Welcome stranger!"
        let customer = CustomerIdentityDTO(idOnExternalPlatform: UUID().uuidString, firstName: "John", lastName: "Doe")
        
        let parsedMessage = WelcomeMessageManager.parse(sut, with: [:], customer: customer)
        
        XCTAssertEqual(expectation, parsedMessage, "Parsed message is not same as original one. Parsed message - \(parsedMessage)")
    }
    
    func testFallBackWelcomeMessage() {
        sut = "Welcome {{customer.firstName|stranger}}!"
        expectation = "Welcome stranger!"
        let customer = CustomerIdentityDTO(idOnExternalPlatform: UUID().uuidString, firstName: "", lastName: "")
        
        let parsedMessage = WelcomeMessageManager.parse(sut, with: [:], customer: customer)
        
        XCTAssertEqual(expectation, parsedMessage, "Parsed message is not same as original one. Parsed message - \(parsedMessage)")
    }
    
    func testFallBackWelcomeMessageCustomFieldsEmptyValue() {
        sut = "Welcome {{customer.firstName|stranger}}!"
        expectation = "Welcome stranger!"
        let customer = CustomerIdentityDTO(idOnExternalPlatform: UUID().uuidString, firstName: "", lastName: "")
        
        let parsedMessage = WelcomeMessageManager.parse(sut, with: [:], customer: customer)
        
        XCTAssertEqual(expectation, parsedMessage, "Parsed message is not same as original one. Parsed message - \(parsedMessage)")
    }
    
    func testWelcomeMessageWithVariable() {
        sut = "Welcome {{customer.firstName|stranger}}!"
        expectation = "Welcome John!"
        let customer = CustomerIdentityDTO(idOnExternalPlatform: UUID().uuidString, firstName: "John", lastName: "Doe")
        
        let parsedMessage = WelcomeMessageManager.parse(sut, with: [:], customer: customer)
        
        XCTAssertEqual(expectation, parsedMessage, "Parsed message is not same as original one. Parsed message - \(parsedMessage)")
    }
    
    func testFallBackWelcomeMessageWithVariable() {
        sut = "Welcome {{customer.firstName|stranger}}!"
        expectation = "Welcome stranger!"
        let customer = CustomerIdentityDTO(idOnExternalPlatform: UUID().uuidString, firstName: "", lastName: "")
        
        let parsedMessage = WelcomeMessageManager.parse(sut, with: [:], customer: customer)
        
        XCTAssertEqual(expectation, parsedMessage, "Parsed message is not same as original one. Parsed message - \(parsedMessage)")
    }
    
    func testWelcomeMessageWithVariables() {
        sut = "Welcome {{customer.firstName}} {{customer.lastName}}!"
        expectation = "Welcome John Doe!"
        let customer = CustomerIdentityDTO(idOnExternalPlatform: UUID().uuidString, firstName: "John", lastName: "Doe")
        
        let parsedMessage = WelcomeMessageManager.parse(sut, with: [:], customer: customer)
        
        XCTAssertEqual(expectation, parsedMessage, "Parsed message is not same as original one. Parsed message - \(parsedMessage)")
    }
    
    func testComplexWelcomeMessage() {
        sut = "Dear {{customer.firstName|customer}}, we would like to offer you a discount of {{customer.customFields.discount-value|5 %}}."
        expectation = "Dear John, we would like to offer you a discount of 7.5 %."
        let customer = CustomerIdentityDTO(idOnExternalPlatform: UUID().uuidString, firstName: "John", lastName: "Doe")
        
        let parsedMessage = WelcomeMessageManager.parse(sut, with: ["discount-value": "7.5 %"], customer: customer)
        
        XCTAssertEqual(expectation, parsedMessage, "Parsed message is not same as original one. Parsed message - \(parsedMessage)")
    }
    
    func testFallbackComplexWelcomeMessage() {
        sut = "Dear {{customer.firstName|customer}}, we would like to offer you a discount of {{customer.customFields.discountValue|5 %}}."
        expectation = "Dear customer, we would like to offer you a discount of 5 %."
        let customer = CustomerIdentityDTO(idOnExternalPlatform: UUID().uuidString, firstName: "", lastName: "")
        
        let parsedMessage = WelcomeMessageManager.parse(sut, with: [:], customer: customer)
        
        XCTAssertEqual(expectation, parsedMessage, "Parsed message is not same as original one. Parsed message - \(parsedMessage)")
    }
    
    func testCombiningContactAndCustomerFields() {
        sut = "Dear {{customer.firstName|customer}}, we would like to offer you a discount of {{contact.customFields.discount_value|5 %}}."
                + " Do you have {{customer.customFields.minutes|15 minutes}}?"
        expectation = "Dear John, we would like to offer you a discount of 2.5 %. Do you have 10 minutes?"
        let customer = CustomerIdentityDTO(idOnExternalPlatform: UUID().uuidString, firstName: "John", lastName: "Doe")
        let customFields = [
            "discount_value": "2.5 %",
            "minutes": "10 minutes"
        ]
        
        let parsedMessage = WelcomeMessageManager.parse(sut, with: customFields, customer: customer)
        
        XCTAssertEqual(expectation, parsedMessage, "Parsed message is not same as original one. Parsed message - \(parsedMessage)")
    }
}
