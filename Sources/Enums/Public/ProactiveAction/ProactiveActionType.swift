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

/// Represents the types of proactive actions that can be triggered.
///
/// Use this enum to specify which proactive action should be performed, such as displaying a custom popup
/// or handling inactivity events.
public enum ProactiveActionType: Sendable {

    /// Triggers the display of an inactivity popup.
    ///
    /// - Parameter inactivityPopup: The `InactivityPopup` instance associated with the inactivity event.
    case inactivityPopup(InactivityPopup)

    /// Delivers a satisfaction survey received from the chat.
    ///
    /// The survey is excluded from the chat transcript. Use its prompt and URL to present the survey in your application.
    ///
    /// The URL is supplied by the backend and is not validated or sanitised by the SDK. When loading it in a web view,
    /// verify that it uses `https` and restrict navigation to the survey origin.
    ///
    /// A survey that arrives while the application is not connected is delivered when the thread is next recovered,
    /// and only once — the SDK records delivery on this device when it emits the event and does not emit it again for
    /// that thread. Present the survey when you receive it: there is no second delivery, and the SDK cannot detect
    /// that your application was unable to present it.
    ///
    /// - Parameter satisfactionSurvey: The `SatisfactionSurvey` received from the chat.
    case satisfactionSurvey(SatisfactionSurvey)
}
