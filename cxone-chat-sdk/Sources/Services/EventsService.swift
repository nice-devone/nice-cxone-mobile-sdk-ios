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

import Foundation

final class EventsService {
    
    // MARK: - Properties
    
    private let encoder = JSONEncoder()
    
    var connectionContext: ConnectionContext
    
    // MARK: - Init
    
    init(connectionContext: ConnectionContext) {
        self.connectionContext = connectionContext
    }
    
    // MARK: - Methods
    
    /// - Throws: ``CXoneChatError/customerAssociationFailure`` if the SDK could not get customer identity and it may not have been set.
    /// - Throws: ``EncodingError.invalidValue(_:_:)`` if the given value is invalid in the current context for this format.
    func create(_ eventType: EventType, with eventData: EventDataType? = nil) throws -> Data {
        LogManager.trace("Creating an event of type - \(eventType).")
        
        guard let customer = connectionContext.customer else {
            throw CXoneChatError.customerAssociationFailure
        }
        
        var event = EventDTO(
            brandId: connectionContext.brandId,
            channelId: connectionContext.channelId,
            customerIdentity: customer,
            eventType: eventType,
            data: eventData
        )
        
        if let visitorId = connectionContext.visitorId {
            event.payload.visitorId = LowerCaseUUID(uuid: visitorId)
        }
        
        return try encoder.encode(event)
    }
}
