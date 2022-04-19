//
//  File.swift
//  
//
//  Created by kjoe on 2/9/22.
//

import Foundation
struct LoadMoreMessageEvent {
    let action: String
    let eventId: UUID
    let payload: LoadMoreMessagePayload
}

extension LoadMoreMessageEvent: Encodable {}

/// The `payload` of a `LoadMoreMessageEvent`
 struct LoadMoreMessagePayload {
    let brand: Brand
    let channel: Channel
    let data: LoadMoreMessageData
    let consumerIdentity: CustomerIdentity
    let eventType: String
}

extension LoadMoreMessagePayload: Encodable {}

struct LoadMoreMessageData {
    let scrollToken: String
    let thread: CustomFieldThreadCodable
    let oldestMessageDatetime: String
    let consumerContact: Contact?
}

extension LoadMoreMessageData: Encodable {}

struct LoadMoreMessagesResponse {
    let eventId: String
    let postback: MoreMessagePostBack
}
extension LoadMoreMessagesResponse: Codable {}

struct MoreMessagePostBack {
    let eventType: String
    let data: MoreMessagePostBackData
}
extension MoreMessagePostBack: Codable {}

struct MoreMessagePostBackData {
    let messages: [MessagePostback]
    let scrollToken: String
}
extension MoreMessagePostBackData: Codable {}


