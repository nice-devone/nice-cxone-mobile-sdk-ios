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

// MARK: - SatisfactionSurvey

/// Represents the structured data of a satisfaction survey received within a chat session.
///
/// The `SatisfactionSurvey` encapsulates the information needed to present a survey to the customer —
/// a text prompt inviting the customer to fill out the survey, the URL of the survey web page,
/// and the identifier of the thread the survey belongs to.
/// Satisfaction survey messages are not part of the regular chat transcript; they are handled separately.
public struct SatisfactionSurvey: Equatable, Sendable {

    // MARK: - Properties

    /// The prompt text to display to the customer.
    public let prompt: String

    /// The URL of the survey page.
    public let url: URL

    /// The identifier of the thread the survey belongs to, matching ``ChatThread/id``.
    ///
    /// Use it to present the survey with its own conversation - for example, to hold it back while the customer
    /// is viewing a different thread and present it once they open this one.
    public let threadId: String
}
