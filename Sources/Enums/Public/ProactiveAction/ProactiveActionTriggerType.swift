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

/// Represents the types of proactive actions that can be triggered.
///
/// Use this enum to specify which proactive action should be performed, such as refreshing or expiring a session
/// in response to an inactivity popup.
public enum ProactiveActionTriggerType: Equatable {
    
    /// Triggers a session refresh, typically when an inactivity popup appears.
    ///
    /// - Parameter: The `InactivityPopup` instance associated with the refresh action.
    case refreshSession(InactivityPopup)
    
    /// Triggers a session expiration, typically when an inactivity popup indicates the session should end.
    ///
    /// - Parameter: The `InactivityPopup` instance associated with the expire action.
    case expireSession(InactivityPopup)
}
