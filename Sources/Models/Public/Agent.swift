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

/// Represents all info about an agent.
public struct Agent: Equatable {
    
    /// The id of the agent.
    public let id: Int

    /// The first name of the agent.
    public let firstName: String

    /// The surname of the agent.
    public let surname: String

    /// The nickname of the agent.
    public let nickname: String?

    /// Whether the agent is a bot.
    public let isBotUser: Bool

    /// Whether the agent is for automated surveys.
    public let isSurveyUser: Bool

    /// The URL for the profile photo of the agent.
    public let imageUrl: String

    /// The full name of the agent (readonly).
    public var fullName: String {
        "\(firstName) \(surname)"
    }
}
