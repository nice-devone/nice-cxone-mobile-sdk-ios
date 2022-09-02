import Foundation

public struct ThreadRecoveredEventPostback: Codable {
    public var eventType: EventType
    public var data: ThreadRecoveredEventPostbackData
}

