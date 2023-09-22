import Foundation
@testable import CXoneChatSDK

struct EventPayLoadCodable: Codable {
    let action: String
    let payload: MockPayload
}

struct MockPayload: Codable {
    let eventType: EventType
}
