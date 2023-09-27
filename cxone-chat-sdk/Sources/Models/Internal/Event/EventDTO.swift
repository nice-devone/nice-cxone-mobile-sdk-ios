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

/// An event to be sent through the WebSocket.
struct EventDTO: Encodable {

    // MARK: - Properties

    /// The action that was performed for the event.
    let action: EventActionType

    /// The unique id for the event.
    let eventId = UUID()
    
    /// The event details.
    var payload: EventPayloadDTO
    
    // MARK: - Init
    
    init(brandId: Int, channelId: String, customerIdentity: CustomerIdentityDTO, eventType: EventType, data: EventDataType?) {
        payload = EventPayloadDTO(brandId: brandId, channelId: channelId, customerIdentity: customerIdentity, eventType: eventType, data: data)
        action = (eventType == .authorizeCustomer || eventType == .refreshToken) ? .register : .chatWindowEvent
    }
}
