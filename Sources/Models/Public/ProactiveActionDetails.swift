import Foundation


/// Represents all info about details of a proactive action.
public struct ProactiveActionDetails {
    
    // MARK: - Properties

    /// The unique id of the action.
    public let id: UUID

    /// The name of the action.
    public let name: String

    /// The type of proactive action.
    public let type: ActionType

    /// Proactive action data message content.
    public let content: ProactiveActionDataMessageContent?
    
    
    // MARK: - Init
    
    /// - Parameters:
    ///   - id: The unique id of the action.
    ///   - name: The name of the action.
    ///   - type: The type of proactive action.
    ///   - data: The data of the action.
    public init(id: UUID, name: String, type: ActionType, content: ProactiveActionDataMessageContent?) {
        self.id = id
        self.name = name
        self.type = type
        self.content = content
    }
}
