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

import Foundation

// MARK: - InactivityPopup

/// Represents the structured data required to display and manage an inactivity popup within a chat session.
///
/// The `InactivityPopup` encapsulates all information needed to present a user-facing popup when inactivity is detected.
/// It includes the popup's title, message body, countdown timer, and associated action buttons for refreshing or expiring the session.
/// This struct is typically used to prompt the user to take action before their session expires due to inactivity.
///
/// - Note: The countdown is managed using `numberOfSeconds` and `startedAt`, allowing calculation of the remaining time.
public struct InactivityPopup: Equatable {
    
    // MARK: - Properties
    
    /// The title of the popup.
    public let title: String
    
    /// The message body of the popup.
    ///
    /// It's a combination of body text and the call to action text from the configuration.
    public let message: String
    
    /// The countdown duration in seconds.
    ///
    /// This is the total time for the countdown. The actual remaining time can be calculated
    /// by subtracting the elapsed time since `startedAt` from this value.
    public let numberOfSeconds: Int
    
    /// The ISO8601 date when the countdown started.
    public let startedAt: Date
    
    /// The thread ID associated with the popup.
    public let threadId: UUID
    
    /// The button to refresh the session.
    public let refreshButton: InactivityPopupButton
    
    /// The button to expire the session.
    public let expireButton: InactivityPopupButton
}
