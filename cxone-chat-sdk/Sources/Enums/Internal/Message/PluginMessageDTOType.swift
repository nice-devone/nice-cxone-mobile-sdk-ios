//
// Copyright (c) 2021-2023. NICE Ltd. All rights reserved.
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

enum PluginMessageDTOType {
    
    case gallery([PluginMessageDTOType])
    
    case menu(PluginMessageMenuDTO)
    
    case textAndButtons(PluginMessageTextAndButtonsDTO)
    
    case quickReplies(PluginMessageQuickRepliesDTO)
    
    case satisfactionSurvey(PluginMessageSatisfactionSurveyDTO)
    
    case custom(PluginMessageCustomDTO)
    
    case subElements([PluginMessageSubElementDTOType])
}

// MARK: - Codable

extension PluginMessageDTOType: Codable {
    
    init(from decoder: Decoder) throws {
        let singleValueContainer = try decoder.singleValueContainer()
        
        if let object = try? singleValueContainer.decode(PluginMessageTextAndButtonsDTO.self) {
            self = .textAndButtons(object)
        } else if let object = try? singleValueContainer.decode(PluginMessageQuickRepliesDTO.self) {
            self = .quickReplies(object)
        } else if let object = try? singleValueContainer.decode(PluginMessageMenuDTO.self) {
            self = .menu(object)
        } else if let object = try? singleValueContainer.decode(PluginMessageSatisfactionSurveyDTO.self) {
            self = .satisfactionSurvey(object)
        } else if let object = try? singleValueContainer.decode(PluginMessageCustomDTO.self) {
            self = .custom(object)
        } else if let objects = try? singleValueContainer.decode([PluginMessageSubElementDTOType].self) {
            self = .subElements(objects)
        } else {
            throw DecodingError.dataCorrupted(DecodingError.Context(codingPath: singleValueContainer.codingPath, debugDescription: "PluginMessageType"))
        }
    }
    
    func encode(to encoder: Encoder) throws {
        var singleContainer = encoder.singleValueContainer()
        
        switch self {
        case .gallery(let entities):
            try singleContainer.encode(entities)
        case .quickReplies(let entity):
            try singleContainer.encode(entity)
        case .textAndButtons(let entity):
            try singleContainer.encode(entity)
        case .menu(let entity):
            try singleContainer.encode(entity)
        case.satisfactionSurvey(let entity):
            try singleContainer.encode(entity)
        case .custom(let entity):
            try singleContainer.encode(entity)
        case .subElements(let entities):
            try singleContainer.encode(entities)
        }
    }
}
