//
//  File.swift
//  
//
//  Created by Tyler Hendrickson on 3/5/22.
//

import Foundation

/// The types of data that can be sent on an event.
enum EventData: Encodable {
    case archiveThread(RecoverThreadData)
    case message(MessageEventData)
    case archiveThreadData(ArchiveThreadData)
    case loadMoreMessageData(LoadMoreMessageData)
    case setContactCustomFieldData(SetContactCustomFieldData)
    case setCustomerCustomFieldData(SetCustomerCustomFieldData)
    case clientTypingStartedData(ClientTypingStartedData)
    case connectUserAuth(ConnectUserAuth)
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        switch self {
        case .archiveThread(let thread):
            try container.encode(thread)
        case .message(let message):
            try container.encode(message)
        case .archiveThreadData(let thread):
            try container.encode(thread)
        case .loadMoreMessageData(let moreMessageData):
            try container.encode(moreMessageData)
        case .setContactCustomFieldData(let data):
            try container.encode(data)
        case .setCustomerCustomFieldData(let data):
            try container.encode(data)
        case .clientTypingStartedData(let data):
            try container.encode(data)
        case .connectUserAuth(let data):
            try container.encode(data)
        }
    }
}

// Save for future reference
///// The `data` of a `MessagePost`
//public struct MessagePostData {
//    public var thread: MessageThreadCodable
//    public var messageContent: MessageContent
//    public var idOnExternalPlatform: UUID
//    public var consumer: CustomerFields
//    public var consumerContact: CustomerFields
//    public var attachments: [Attachment]
//    public var browserFingerprint: BrowserFingerprint
//
//    public init(thread: MessageThreadCodable, messageContent: MessageContent, idOnExternalPlatform: UUID, customer: CustomerFields, contact: CustomerFields, attachments: [Attachment], browserFingerPrint: BrowserFingerprint) {
//        self.thread = thread
//        self.messageContent = messageContent
//        self.idOnExternalPlatform = idOnExternalPlatform
//        self.consumer = customer
//        self.consumerContact = contact
//        self.attachments = attachments
//        self.browserFingerprint = browserFingerPrint
//    }
//}

