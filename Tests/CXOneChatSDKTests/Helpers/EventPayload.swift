import Foundation
@testable import CXOneChatSDK

struct EventPayLoadCodable {
    let action: String
    let payload: MockPayload
}
struct MockPayload {
    let eventType: EventType
}
extension MockPayload: Codable {}
extension EventPayLoadCodable: Codable {}
