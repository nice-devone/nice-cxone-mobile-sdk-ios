//
//  File.swift
//  
//
//  Created by kjoe on 3/15/22.
//

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
