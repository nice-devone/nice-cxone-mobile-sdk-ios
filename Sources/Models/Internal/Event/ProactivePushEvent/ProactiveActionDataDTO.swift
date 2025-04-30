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

/// Represents info about data of a proactive action.
struct ProactiveActionDataDTO: Equatable {
    
    // MARK: - Properties
    
    /// Proactive action data message content.
    let content: ProactiveActionDataMessageContentDTO
    
    let customFields: [CustomFieldDTO]
    
    let templateType: TemplateIdType?
    
    let call2action: CallToActionDTO?
    
    let design: DesignDTO?
    
    let position: Position?
    
    let customJs: String?
}

// MARK: - Codable

extension ProactiveActionDataDTO: Codable {
    
    enum CodingKeys: CodingKey {
        case content
        case handover
        case template
        case call2action
        case design
        case position
        case customization
    }
    
    enum HandoverKeys: CodingKey {
        case customFields
    }
    
    enum CustomizationKeys: CodingKey {
        case customJs
    }
    
    enum TemplateKeys: CodingKey {
        case id
    }
    
    enum PositionKeys: String, CodingKey {
        case general
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let handoverContainer = try container.nestedContainer(keyedBy: HandoverKeys.self, forKey: .handover)
        let customizationContainer = try? container.nestedContainer(keyedBy: CustomizationKeys.self, forKey: .customization)
        let templateContainer = try? container.nestedContainer(keyedBy: TemplateKeys.self, forKey: .template)
        let positionContainer = try? container.nestedContainer(keyedBy: PositionKeys.self, forKey: .position)
        
        self.content = try container.decode(ProactiveActionDataMessageContentDTO.self, forKey: .content)
        self.customFields = try handoverContainer.decode([CustomFieldDTO].self, forKey: .customFields)
        self.templateType = try templateContainer?.decodeIfPresent(TemplateIdType.self, forKey: .id)
        self.call2action = try container.decodeIfPresent(CallToActionDTO.self, forKey: .call2action)
        self.design = try container.decodeIfPresent(DesignDTO.self, forKey: .design)
        self.position = try positionContainer?.decodeIfPresent(Position.self, forKey: .general)
        self.customJs = try customizationContainer?.decodeIfPresent(String.self, forKey: .customJs)
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        var handoverContainer = container.nestedContainer(keyedBy: HandoverKeys.self, forKey: .handover)

        try container.encode(content, forKey: .content)
        try container.encodeIfPresent(call2action, forKey: .call2action)
        try container.encodeIfPresent(design, forKey: .design)
        try handoverContainer.encode(customFields, forKey: .customFields)
        
        if let templateType = templateType {
            var templateContainer = container.nestedContainer(keyedBy: TemplateKeys.self, forKey: .template)
            
            try templateContainer.encodeIfPresent(templateType, forKey: .id)
        }
        if let position = position {
            var positionContainer = container.nestedContainer(keyedBy: PositionKeys.self, forKey: .position)
            
            try positionContainer.encodeIfPresent(position, forKey: .general)
        }
        if let customJs = customJs {
            var customizationContainer = container.nestedContainer(keyedBy: CustomizationKeys.self, forKey: .customization)
            
            try customizationContainer.encodeIfPresent(customJs, forKey: .customJs)
        }
    }
}
