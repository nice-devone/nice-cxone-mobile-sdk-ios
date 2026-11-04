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

/// Type-safe enum for satisfaction survey elements with associated values.
enum SatisfactionSurveyElementDTOType: Equatable {

    /// Text/prompt element.
    case text(SatisfactionSurveyTextElementDTO)

    /// Iframe button element carrying the survey URL.
    case iframeButton(SatisfactionSurveyButtonElementDTO)
}

// MARK: - Decodable

extension SatisfactionSurveyElementDTOType: Decodable {

    enum CodingKeys: CodingKey {
        case type
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let singleContainer = try decoder.singleValueContainer()

        let elementType = try container.decode(ElementType.self, forKey: .type)

        switch elementType {
        case .text:
            self = .text(try singleContainer.decode(SatisfactionSurveyTextElementDTO.self))
        case .iframeButton:
            self = .iframeButton(try singleContainer.decode(SatisfactionSurveyButtonElementDTO.self))
        default:
            throw DecodingError.valueNotFound(
                SatisfactionSurveyElementDTOType.self,
                DecodingError.Context(codingPath: container.codingPath, debugDescription: "Unsupported satisfaction survey element type: \(elementType)")
            )
        }
    }
}

#if DEBUG
// MARK: - Encodable

extension SatisfactionSurveyElementDTOType: Encodable {

    func encode(to encoder: Encoder) throws {
        switch self {
        case .text(let textElement):
            try textElement.encode(to: encoder)
        case .iframeButton(let buttonElement):
            try buttonElement.encode(to: encoder)
        }
    }
}
#endif
