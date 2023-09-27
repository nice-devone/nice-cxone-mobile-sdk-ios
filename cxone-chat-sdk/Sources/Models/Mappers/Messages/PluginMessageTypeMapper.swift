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

enum PluginMessageTypeMapper {
    
    static func map(_ entity: PluginMessageType) throws -> PluginMessageDTOType {
        switch entity {
        case .gallery(let entities):
            return .gallery(try entities.map(Self.map))
        case .menu(let entity):
            return .menu(PluginMessageMenuMapper.map(entity))
        case .textAndButtons(let entity):
            return .textAndButtons(PluginMessageTextAndButtonsMapper.map(entity))
        case .quickReplies(let entity):
            return .quickReplies(PluginMessageQuickRepliesMapper.map(entity))
        case .satisfactionSurvey(let entity):
            return .satisfactionSurvey(PluginMessageSatisfactionSurveyMapper.map(entity))
        case .subElements(let entities):
            return .subElements(entities.map(PluginMessageSubElementMapper.map))
        case .custom(let entity):
            return .custom(try PluginMessageCustomMapper.map(entity))
        }
    }
    
    static func map(_ entity: PluginMessageDTOType) -> PluginMessageType {
        switch entity {
        case .gallery(let entities):
            return .gallery(entities.map(Self.map))
        case .menu(let entity):
            return .menu(PluginMessageMenuMapper.map(entity))
        case .textAndButtons(let entity):
            return .textAndButtons(PluginMessageTextAndButtonsMapper.map(entity))
        case .quickReplies(let entity):
            return .quickReplies(PluginMessageQuickRepliesMapper.map(entity))
        case .satisfactionSurvey(let entity):
            return .satisfactionSurvey(PluginMessageSatisfactionSurveyMapper.map(entity))
        case .subElements(let entities):
            return .subElements(entities.map(PluginMessageSubElementMapper.map))
        case .custom(let entity):
            return .custom(PluginMessageCustomMapper.map(entity))
        }
    }
}

// MARK: - PluginMessageMenuMapper

private enum PluginMessageMenuMapper {
    
    static func map(_ entity: PluginMessageMenu) -> PluginMessageMenuDTO {
        PluginMessageMenuDTO(id: entity.id, elements: entity.elements.map(PluginMessageSubElementMapper.map))
    }
    
    static func map(_ entity: PluginMessageMenuDTO) -> PluginMessageMenu {
        PluginMessageMenu(id: entity.id, elements: entity.elements.map(PluginMessageSubElementMapper.map))
    }
}

// MARK: - PluginMessageTextAndButtonsMapper

private enum PluginMessageTextAndButtonsMapper {
    
    static func map(_ entity: PluginMessageTextAndButtons) -> PluginMessageTextAndButtonsDTO {
        PluginMessageTextAndButtonsDTO(id: entity.id, elements: entity.elements.map(PluginMessageSubElementMapper.map))
    }
    
    static func map(_ entity: PluginMessageTextAndButtonsDTO) -> PluginMessageTextAndButtons {
        PluginMessageTextAndButtons(id: entity.id, elements: entity.elements.map(PluginMessageSubElementMapper.map))
    }
}

// MARK: - PluginMessageQuickRepliesMapper

private enum PluginMessageQuickRepliesMapper {
    
    static func map(_ entity: PluginMessageQuickReplies) -> PluginMessageQuickRepliesDTO {
        PluginMessageQuickRepliesDTO(id: entity.id, elements: entity.elements.map(PluginMessageSubElementMapper.map))
    }
    
    static func map(_ entity: PluginMessageQuickRepliesDTO) -> PluginMessageQuickReplies {
        PluginMessageQuickReplies(id: entity.id, elements: entity.elements.map(PluginMessageSubElementMapper.map))
    }
}

// MARK: - PluginMessageSatisfactionSurveyMapper

private enum PluginMessageSatisfactionSurveyMapper {
    
    static func map(_ entity: PluginMessageSatisfactionSurvey) -> PluginMessageSatisfactionSurveyDTO {
        PluginMessageSatisfactionSurveyDTO(id: entity.id, elements: entity.elements.map(PluginMessageSubElementMapper.map))
    }
    
    static func map(_ entity: PluginMessageSatisfactionSurveyDTO) -> PluginMessageSatisfactionSurvey {
        PluginMessageSatisfactionSurvey(id: entity.id, elements: entity.elements.map(PluginMessageSubElementMapper.map))
    }
}

// MARK: - PluginMessageCustomMapper

private enum PluginMessageCustomMapper {
    
    static func map(_ entity: PluginMessageCustomDTO) -> PluginMessageCustom {
        var variables = [String: Any]()
        
        for (key, value) in entity.variables {
            variables[key] = CodableObjectMapper.map(value)
        }
        
        return PluginMessageCustom(id: entity.id, text: entity.text, variables: variables)
    }
    
    static func map(_ entity: PluginMessageCustom) throws -> PluginMessageCustomDTO {
        var variables = [String: CodableObject]()
        
        for (key, value) in entity.variables {
            variables[key] = try CodableObjectMapper.map(value)
        }
        
        return PluginMessageCustomDTO(id: entity.id, text: entity.text, variables: variables)
    }
}

// MARK: - CodableObjectMapper

private enum CodableObjectMapper {
    
    static func map(_ entity: CodableObject) -> Any {
        switch entity {
        case .int(let value):
            return value
        case .double(let value):
            return value
        case .string(let value):
            return value
        case .bool(let value):
            return value
        case .dictionary(let dictionary):
            var variables = [String: Any]()
            
            for (key, value) in dictionary {
                variables[key] = Self.map(value)
            }
            
            return variables
        case .array(let array):
            return array.map { Self.map($0) }
        }
    }
    
    static func map(_ entity: Any) throws -> CodableObject {
        switch entity {
        case let value as Bool where entity is Bool:
            return .bool(value)
        case let value as String where entity is String:
            return .string(value)
        case let value as Int where entity is Int:
            return .int(value)
        case let value as Double where entity is Double:
            return .double(value)
        case let dictionary as [String: Any] where entity is [String: Any]:
            var result = [String: CodableObject]()
            
            for (key, value) in dictionary {
                result[key] = try Self.map(value)
            }
            
            return .dictionary(result)
        case let array as [Any] where entity is [Any]:
            return try .array(array.map { try Self.map($0) })
        default:
            throw DecodingError.valueNotFound(CodableObject.self, DecodingError.Context(codingPath: [], debugDescription: "entity"))
        }
    }
}
