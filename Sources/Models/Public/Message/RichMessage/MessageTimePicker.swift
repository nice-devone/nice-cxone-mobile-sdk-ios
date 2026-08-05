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

/// A time slot picker displays a list of options, and information about the time slot.
///
/// A model representing a time picker message, including the text shown in the conversation,
/// the sheet title, and the available time slots. Used to configure UI that presents time slot selection to the user.
public struct MessageTimePicker: Equatable, Sendable {
    
    /// Text displayed in the conversation cell.
    public let title: String
    
    /// Title shown at the top of the time picker sheet.
    public let sheetTitle: String
    
    /// List of available time slot options.
    public let timeSlots: [MessageTimePickerTimeSlot]

    // MARK: - Init

    /// Creates a `MessageTimePicker`.
    ///
    /// - Parameters:
    ///   - title: Text displayed in the conversation cell.
    ///   - sheetTitle: Title shown at the top of the picker sheet when the user opens it.
    ///   - timeSlots: The selectable time slots offered to the user.
    public init(title: String, sheetTitle: String, timeSlots: [MessageTimePickerTimeSlot]) {
        self.title = title
        self.sheetTitle = sheetTitle
        self.timeSlots = timeSlots
    }
}
