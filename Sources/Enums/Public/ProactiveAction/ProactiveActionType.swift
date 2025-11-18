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

/// Represents the types of proactive actions that can be triggered.
///
/// Use this enum to specify which proactive action should be performed, such as displaying a custom popup
/// or handling inactivity events.
public enum ProactiveActionType {

    /// Triggers the display of a custom popup box with the provided data.
    ///
    /// - Parameter data: A dictionary containing the data required to configure the custom popup.
    case customPopupBox(data: [String: Any])
    
    /// Triggers the display of an inactivity popup.
    ///
    /// - Parameter inactivityPopup: The `InactivityPopup` instance associated with the inactivity event.
    case inactivityPopup(InactivityPopup)
}
