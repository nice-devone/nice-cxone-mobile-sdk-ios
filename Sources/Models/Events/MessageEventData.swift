//
//  File.swift
//  
//
//  Created by Tyler Hendrickson on 3/6/22.
//

import Foundation

struct MessageEventData: Codable {
    public var thread: MessageThreadCodable
    public var messageContent: MessageContent
    public var idOnExternalPlatform: UUID
    public var consumer: CustomerFields
    public var consumerContact: CustomerFields
    public var attachments: [Attachment]
    public var browserFingerprint: BrowserFingerprint
    public var accessToken: AccessTokenPayload?
    
    public init(thread: MessageThreadCodable, messageContent: MessageContent, idOnExternalPlatform: UUID, customer: CustomerFields, contact: CustomerFields, accessToken: AccessTokenPayload? = nil, attachments: [Attachment], browserFingerPrint: BrowserFingerprint) {
        self.accessToken = accessToken
        self.thread = thread
        self.messageContent = messageContent
        self.idOnExternalPlatform = idOnExternalPlatform
        self.consumer = customer
        self.consumerContact = contact
        self.attachments = attachments
        self.browserFingerprint = browserFingerPrint
    }
}
