import Foundation


/// Represents all info about details of a proactive action.
struct ProactiveActionDetailsDTO: Codable {

    /// The unique id of the action.
    let actionId: LowerCaseUUID

    /// The name of the action.
    let actionName: String

    /// The type of proactive action.
    let actionType: ActionType

    /// The data of the action.
    let data: ProactiveActionDataDTO?
}
