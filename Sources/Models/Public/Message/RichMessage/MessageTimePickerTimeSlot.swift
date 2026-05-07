//
// Copyright (c) 2021-2026. NICE Ltd. All rights reserved.
//
// Licensed under the NICE License;
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//    https://github.com/nice-devone/nice-cxone-mobile-sdk-ios/blob/main/LICENSE
//
// TO THE EXTENT PERMITTED BY APPLICABLE LAW, THE CXONE MOBILE SDK IS PROVIDED ON
// AN "AS IS" BASIS. NICE HEREBY DISCLAIMS ALL WARRANTIES AND CONDITIONS, EXPRESS
// OR IMPLIED, INCLUDING (WITHOUT LIMITATION) WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE, NON-INFRINGEMENT, AND TITLE.
//

import Foundation

/// A single selectable time slot used by ``MessageTimePicker``
///
/// It contains an identifier, duration, and the start date/time for the slot
public struct MessageTimePickerTimeSlot: Equatable {
    
    /// Unique identifier for the time slot.
    public let id: String
    
    /// Duration of the time slot, in seconds.
    public let duration: Int
    
    /// Start date and time of the slot.
    public let startTime: Date
}
