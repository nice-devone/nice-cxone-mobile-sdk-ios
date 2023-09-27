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
