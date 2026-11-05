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

/// Strongly-typed payload for a satisfaction survey inside a plugin message
struct MessageSatisfactionSurveyDTO: Equatable, Sendable {

    // MARK: - Properties

    /// Element identifier of the satisfaction survey container.
    let id: String

    /// The text prompt element of the survey.
    let text: SatisfactionSurveyTextElementDTO

    /// The iframe button element carrying the survey URL.
    let button: SatisfactionSurveyButtonElementDTO
}

// MARK: - Decodable

extension MessageSatisfactionSurveyDTO: Decodable {

    enum CodingKeys: String, CodingKey {
        case id
        case type
        case elements
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        guard try container.decode(ElementType.self, forKey: .type) == .satisfactionSurvey else {
            throw DecodingError.dataCorruptedError(forKey: .type, in: container, debugDescription: "Element is not a satisfaction survey plugin.")
        }

        self.id = try container.decode(String.self, forKey: .id)

        let elements = try container.decode([SatisfactionSurveyElementDTOType].self, forKey: .elements)

        var textElement: SatisfactionSurveyTextElementDTO?
        var buttonElement: SatisfactionSurveyButtonElementDTO?

        for element in elements {
            switch element {
            case .text(let entity):
                textElement = textElement ?? entity
            case .iframeButton(let entity):
                buttonElement = buttonElement ?? entity
            }
        }

        guard let textElement else {
            throw DecodingError.dataCorruptedError(forKey: .elements, in: container, debugDescription: "Missing text prompt in satisfaction survey.")
        }
        guard let buttonElement else {
            throw DecodingError.dataCorruptedError(forKey: .elements, in: container, debugDescription: "Missing iframe button in satisfaction survey.")
        }

        self.text = textElement
        self.button = buttonElement
    }
}
