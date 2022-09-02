import Foundation

public struct GenericEventPostback: Codable {
    public var eventType: EventType?
    public var data: ReceivedThreadsData?
}
