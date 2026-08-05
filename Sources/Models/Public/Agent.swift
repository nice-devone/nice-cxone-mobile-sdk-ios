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

/// Represents all info about an agent.
public struct Agent: Equatable, Sendable {
    
    // MARK: - Properties
    
    private static let personNameComponentsFormatter = PersonNameComponentsFormatter()
    
    /// The id of the agent.
    public let id: Int

    /// The first name of the agent, or `nil` when the backend omits or hides this field.
    public let firstName: String?

    /// The surname of the agent, or `nil` when the backend omits or hides this field.
    public let surname: String?

    /// The nickname of the agent.
    public let nickname: String?

    /// Whether the agent is a bot, or `nil` when the backend omits or hides this field.
    public let isBotUser: Bool?

    /// Whether the agent is for automated surveys, or `nil` when the backend omits or hides this field.
    public let isSurveyUser: Bool?

    /// The URL for the profile photo of the agent, or `nil` when unavailable or hidden by the backend.
    public let imageUrl: String?

    // MARK: - Computed Properties
    
    /// The full name of the agent (readonly).
    ///
    /// Returns `nil` when neither `firstName` nor `surname` is available — e.g. when the
    /// backend hides the agent's personal information — so callers can apply a fallback.
    public var fullName: String? {
        var nameComponents = PersonNameComponents()
        nameComponents.givenName = firstName
        nameComponents.familyName = surname

        return Self.personNameComponentsFormatter.string(from: nameComponents).nilIfEmpty()
    }

    // MARK: - Init

    /// Creates an `Agent` value, typically when synthesising agents for tests, previews, or mocks.
    ///
    /// Production code receives `Agent` values from the SDK on `ChatThread`s and
    /// in ``ChatEvent/agentTyping(isTyping:agent:threadId:)`` events.
    ///
    /// - Parameters:
    ///   - id: Backend identifier for the agent.
    ///   - firstName: Agent's first name; `nil` when omitted or hidden by the backend.
    ///   - surname: Agent's surname; `nil` when omitted or hidden by the backend.
    ///   - nickname: Optional display nickname; UI typically prefers this over `firstName surname`.
    ///   - isBotUser: `true` if the agent is an automated bot; `nil` when omitted or hidden by the backend.
    ///   - isSurveyUser: `true` if the agent represents an automated survey flow; `nil` when omitted or hidden by the backend.
    ///   - imageUrl: URL of the agent's profile photo; `nil` when unavailable or hidden.
    public init(
        id: Int,
        firstName: String? = nil,
        surname: String? = nil,
        nickname: String? = nil,
        isBotUser: Bool? = nil,
        isSurveyUser: Bool? = nil,
        imageUrl: String? = nil
    ) {
        self.id = id
        self.firstName = firstName
        self.surname = surname
        self.nickname = nickname
        self.isBotUser = isBotUser
        self.isSurveyUser = isSurveyUser
        self.imageUrl = imageUrl
    }
}
