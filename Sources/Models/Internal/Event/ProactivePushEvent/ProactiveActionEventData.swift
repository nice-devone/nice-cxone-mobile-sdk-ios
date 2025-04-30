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

struct ProactiveActionEventDataDTO: Equatable {
    
    // MARK: - Properties
    
    let eventId: LowerCaseUUID

    /// The unique id of the action.
    let actionId: LowerCaseUUID

    /// The name of the action.
    let actionName: String

    /// The type of proactive action.
    let actionType: ActionType

    /// The data of the action.
    let data: ProactiveActionDataDTO?
}

// MARK: - Codable

extension ProactiveActionEventDataDTO: Codable {
    
    enum CodingKeys: CodingKey {
        case destination
        case proactiveAction
    }
    
    enum DestinationKeys: String, CodingKey {
        case eventId = "id"
    }
    
    enum ProactiveActionKeys: CodingKey {
        case action
    }
    
    enum ProactiveActionDetailsKeys: CodingKey {
        case actionId
        case actionName
        case actionType
        case data
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let destinationContainer = try container.nestedContainer(keyedBy: DestinationKeys.self, forKey: .destination)
        let actionContainer = try container
            .nestedContainer(keyedBy: ProactiveActionKeys.self, forKey: .proactiveAction)
            .nestedContainer(keyedBy: ProactiveActionDetailsKeys.self, forKey: .action)
        
        self.eventId = try destinationContainer.decode(LowerCaseUUID.self, forKey: .eventId)
        self.actionId = try actionContainer.decode(LowerCaseUUID.self, forKey: .actionId)
        self.actionName = try actionContainer.decode(String.self, forKey: .actionName)
        self.actionType = try actionContainer.decode(ActionType.self, forKey: .actionType)
        self.data = try actionContainer.decodeIfPresent(ProactiveActionDataDTO.self, forKey: .data)
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        var destinationContainer = container.nestedContainer(keyedBy: DestinationKeys.self, forKey: .destination)
        var actionContainer = container.nestedContainer(keyedBy: ProactiveActionKeys.self, forKey: .proactiveAction)
        var actionDetailsContainer = actionContainer.nestedContainer(keyedBy: ProactiveActionDetailsKeys.self, forKey: .action)
        
        try destinationContainer.encode(eventId, forKey: .eventId)
        try actionDetailsContainer.encode(actionId, forKey: .actionId)
        try actionDetailsContainer.encode(actionName, forKey: .actionName)
        try actionDetailsContainer.encode(actionType, forKey: .actionType)
        try actionDetailsContainer.encodeIfPresent(data, forKey: .data)
    }
}
