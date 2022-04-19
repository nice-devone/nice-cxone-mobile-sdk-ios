//
//  File.swift
//  
//
//  Created by kjoe on 2/25/22.
//

import Foundation

import Foundation
struct LoadMetadatPost : Codable {
    let eventId : String?
    let postback : MetaDataPostback?
}

struct MetaDataPostback : Codable {
    let eventType : String?
    let data : MetaDataPostbackData?
}
struct MetaDataPostbackData : Codable {
    let ownerAssignee: OwnerAssignee?
    let lastMessage: LastMessage?
}

struct LastMessage: Codable {
    let messageId: String?
    let idOnExternalPlatform: String?
    let postId: String?
    let isOwn: Bool?
    let caseId: String?
    let replyToMessageId: String?
    let replyToMessageIdOnExternalPlatform: String?
    let url: String?
    let createdAt: String?
    let createdAtIso: String?
    let receivedAt: String?
    let title: String?
    let messageContent: MessageContent?
    let sentiment: String?
    let tagIds: [String]?
    let isRead: Bool?
    let readAt: ReadAt?
    let messageAssignedUser: MessageAssignedUser?
    let attachments: [Attachment]?
    let semanticEntities: [String]?
    let socialAttributes: SocialAttributes?
    let endUser: EndUser?
    let seen: [String]?
    let delivered: [String]?
    let authorEndUserIdentity: AuthorEndUserIdentity?
}

struct EndUser : Codable {
    let id: String?
    let name: String?
    let nickname: String?
}
struct SocialAttributes : Codable {
    let likes: Int?
    let twitterFavorties: Int?
    let facebookLikes: Int?
    let isDeletedOnExternalPlatform: Bool?
}

struct UserFingerprint : Codable {
    let browser: String?
    let browserVersion: String?
    let os: String?
    let osVersion: String?
    let language: String?
    let ip: String?
    let location: String?
    let country: String?
    let deviceType: String?
}
struct AuthorEndUserIdentity : Codable {
    let idOnExternalPlatform: String?
    let firstName: String?
    let lastName: String?
    let nickname: String?
    let image: String?
    let id: String?
    let fullName: String?
}

struct ReadAt: Codable {
    let date: String?
    let timezone: String?
}

