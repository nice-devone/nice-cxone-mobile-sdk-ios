import Foundation


struct ProactiveActionEventDataDTO {
    
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
    
    
    // MARK: - Init
    
    init(eventId: LowerCaseUUID, actionId: LowerCaseUUID, actionName: String, actionType: ActionType, data: ProactiveActionDataDTO?) {
        self.eventId = eventId
        self.actionId = actionId
        self.actionName = actionName
        self.actionType = actionType
        self.data = data
    }
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
