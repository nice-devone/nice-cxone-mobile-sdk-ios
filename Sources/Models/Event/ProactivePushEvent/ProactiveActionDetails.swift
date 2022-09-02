import Foundation
public struct ProactiveActionDetails: Codable {
    /// The unique id of the action.
    let actionId: LowerCaseUUID
    
    /// The name of the action.
    let actionName: String
    
    ///The type of proactive action.
    let actionType: ActionType
    
    /// the data of the action
    let data: ProactiveActionData?
    
    public init(actionId: UUID, actionName: String, actionType: ActionType, data: ProactiveActionData? = nil) {
        self.actionId = LowerCaseUUID(uuid: actionId)
        self.actionName = actionName
        self.actionType = actionType
        self.data = data
    }
}
