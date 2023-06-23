@testable import CXoneChatSDK
import XCTest


class EventsServiceTests: CXoneXCTestCase {
    
    // MARK: - Properties
    
    // swiftlint:disable:next force_cast
    private lazy var eventsService: EventsService = (CXoneChat.connection as! ConnectionService).eventsService
    
    
    // MARK: - Tests
    
    func testCreateThrowsVisitorIdUnsupportedChannelConfig() {
        socketService.connectionContext.visitorId = nil
        
        XCTAssertThrowsError(try eventsService.create(.reconnectCustomer))
    }
    
    func testCreateThrowsCustomerUnsupportedChannelConfig() {
        socketService.connectionContext.visitorId = nil
        
        XCTAssertThrowsError(try eventsService.create(.reconnectCustomer))
    }
    
    func testCreateSuccecsful() {
        eventsService.connectionContext.customer = CustomerIdentityDTO(idOnExternalPlatform: UUID().uuidString, firstName: "John", lastName: "Doe")
        eventsService.connectionContext.visitorId = UUID()
        
        do {
            _ = try eventsService.create(.reconnectCustomer)
        } catch {
            XCTFail(error.localizedDescription)
        }
    }
}
