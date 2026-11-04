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

enum PluginMessageDTOType: Equatable {
    
    case inactivityPopup(MessageInactivityPopupDTO)
    
    case satisfactionSurvey(MessageSatisfactionSurveyDTO)
    
    case unknown
}

// MARK: - Codable

extension PluginMessageDTOType: Decodable {
    
    init(from decoder: Decoder) throws {
        let singleValueContainer = try decoder.singleValueContainer()
        
        if let object = try? singleValueContainer.decode(MessageInactivityPopupDTO.self) {
            self = .inactivityPopup(object)
        } else if let object = try? singleValueContainer.decode(MessageSatisfactionSurveyDTO.self) {
            self = .satisfactionSurvey(object)
        } else {
            self = .unknown
        }
    }
}

#if DEBUG
// MARK: - Encodable

extension PluginMessageDTOType: Encodable {
    
    enum CodingKeys: String, CodingKey {
        case id
        case type
        case elements
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        
        switch self {
        case .inactivityPopup(let popup):
            try encode(popup, to: &container)
        case .satisfactionSurvey(let survey):
            try encode(survey, to: &container)
        case .unknown:
            throw EncodingError.invalidValue(
                self,
                EncodingError.Context(codingPath: encoder.codingPath, debugDescription: "Unsupported plugin message type")
            )
        }
    }
}

// MARK: - Private Methods

private extension PluginMessageDTOType {
    
    func encode(_ popup: MessageInactivityPopupDTO, to container: inout KeyedEncodingContainer<CodingKeys>) throws {
        try container.encode(popup.id, forKey: .id)
        try container.encode(ElementType.inactivityPopup.rawValue, forKey: .type)
        
        let elements: [MessagePluginSubElementDTOType] = [
            .title(InactivityPopupTitleElementDTO(id: popup.title.id, text: popup.title.text)),
            .text(InactivityPopupTextElementDTO(id: popup.body.id, text: popup.body.text)),
            .text(InactivityPopupTextElementDTO(id: popup.callToAction.id, text: popup.callToAction.text)),
            .countdown(
                InactivityPopupCountdownElementDTO(
                    id: popup.id,
                    startedAt: popup.countdown.startedAt,
                    numberOfSeconds: popup.countdown.numberOfSeconds
                )
            ),
            .button(
                InactivityPopupButtonElementDTO(
                    id: popup.expireButton.id,
                    text: popup.expireButton.text,
                    postback: popup.expireButton.postback,
                    isSessionRefresh: false
                )
            ),
            .button(
                InactivityPopupButtonElementDTO(
                    id: popup.refreshButton.id,
                    text: popup.refreshButton.text,
                    postback: popup.refreshButton.postback,
                    isSessionRefresh: false
                )
            )
        ]
        
        try container.encode(elements, forKey: .elements)
    }
    
    func encode(_ survey: MessageSatisfactionSurveyDTO, to container: inout KeyedEncodingContainer<CodingKeys>) throws {
        try container.encode(survey.id, forKey: .id)
        try container.encode(ElementType.satisfactionSurvey.rawValue, forKey: .type)
        
        let elements: [SatisfactionSurveyElementDTOType] = [
            .text(survey.text),
            .iframeButton(survey.button)
        ]
        
        try container.encode(elements, forKey: .elements)
    }
}
#endif
