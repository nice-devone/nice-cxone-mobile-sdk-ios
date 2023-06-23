import XCTest
@testable import CXoneChatSDK


class ConnectionContextTests: XCTestCase {

    // MARK: - Properties
    
    var sut = ConnectionContextImpl(keychainSwift: KeychainSwiftMock(), session: .shared)
    
    
    // MARK: - Tests
    
    func testNotConnected() throws {
        XCTAssertFalse(sut.isConnected)
        
        sut.channelId = "channel_id"
        XCTAssertFalse(sut.isConnected)
        
        sut.brandId = 1234
        XCTAssertFalse(sut.isConnected)
        
        sut.visitorId = UUID()
        XCTAssertFalse(sut.isConnected)
        
        sut.customer = CustomerIdentityDTO(idOnExternalPlatform: UUID().uuidString, firstName: "John", lastName: "Doe")
        XCTAssertTrue(sut.isConnected)
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
        
        XCTAssertNoThrow(try sut.setAccessToken(AccessTokenDTO(token: "data", expiresIn: .max)))
        XCTAssertNotNil(sut.accessToken)
    }
    
    func testPrechatSurveyMapCorrectly() throws {
        let data = try loadStubFromBundle(withName: "ChannelConfiguration", extension: "json")
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
    }
}
