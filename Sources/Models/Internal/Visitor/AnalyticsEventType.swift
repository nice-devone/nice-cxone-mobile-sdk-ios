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

enum AnalyticsEventType: String, CaseIterable, Codable {
    /// Event for the visitor starting a new page visit.
    case visitorVisit = "VisitorVisit"

    /// Event for the visitor viewing a page.
    case pageView = "PageView"

    /// Event for the visitor ending a page view
    case timeSpentOnPage = "TimeSpentOnPage"

    /// Event that the chat window was opened by the visitor.
    case chatWindowOpened = "ChatWindowOpened"

    /// Event that the visitor has followed a proactive action to start a chat.
    case conversion = "Conversion"

    /// Event that the proactive action was successfully displayed to the visitor.
    case proactiveActionDisplayed = "ProactiveActionDisplayed"

    /// Event that the proactive action was clicked by the visitor.
    case proactiveActionClicked = "ProactiveActionClicked"

    /// Event that the proactive action has successfully led to a conversion.
    case proactiveActionSuccess = "ProactiveActionSuccess"

    /// Event that the proactive action has not led to a conversion within a certain time span.
    case proactiveActionFailed = "ProactiveActionFailed"

    /// A custom visitor event to send any additional data.
    case custom = "Custom"
}
