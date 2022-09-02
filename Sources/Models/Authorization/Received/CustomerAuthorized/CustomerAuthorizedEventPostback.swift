import Foundation

public struct CustomerAuthorizedEventPostback: Codable {
    public var eventType: EventType
    public var data: CustomerAuthorizedEventPostbackData
}
