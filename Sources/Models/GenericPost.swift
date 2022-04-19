//
//  Created by Customer Dynamics Development on 9/28/21.
//

import Foundation

/// The initial decoding of a message from the WebSocket.
public struct GenericPost: Codable {
	public var eventId: String
	public var eventType: EventType?
	public var postback: GenericPostback?
    let error : OperationError?
}

/// The `postback` of the `GenericPost`
public struct GenericPostback: Codable {
	public var eventType: EventType?
    public var data: PostBackData?
}

public struct PostBackData: Codable {
    let threads: [PostThreads]?

    enum CodingKeys: String, CodingKey {

        case threads = "threads"
    }

    public init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        threads = try values.decodeIfPresent([PostThreads].self, forKey: .threads)
    }

}
public struct PostThreads : Codable {
    let id : String?
    let channelId : String?
    let idOnExternalPlatform : String?
    let ticketNumber : String?
    let content : String?
    let title : String?
    let threadName : String?
    let url : String?
    let isOwn : Bool?
    let createdAt : String?
    let updatedAt : String?
    let author : Author?
    let image : String?
    let tagIds : [String]?
    let likes : Int?
    let attachments : [String]?
    let recipients : [String]?
    let canAddMoreMessages : Bool?
    let deletedOnExternalPlatform : Bool?
    let unseenMessagesCount : Int?
    let unseenByUserMessagesCount : Int?
    let unseenByEndUserMessagesCount : Int?

    enum CodingKeys: String, CodingKey {

        case id = "id"
        case channelId = "channelId"
        case idOnExternalPlatform = "idOnExternalPlatform"
        case ticketNumber = "ticketNumber"
        case content = "content"
        case title = "title"
        case threadName = "threadName"
        case url = "url"
        case isOwn = "isOwn"
        case createdAt = "createdAt"
        case updatedAt = "updatedAt"
        case author = "author"
        case image = "image"
        case tagIds = "tagIds"
        case likes = "likes"
        case attachments = "attachments"
        case recipients = "recipients"
        case canAddMoreMessages = "canAddMoreMessages"
        case deletedOnExternalPlatform = "deletedOnExternalPlatform"
        case unseenMessagesCount = "unseenMessagesCount"
        case unseenByUserMessagesCount = "unseenByUserMessagesCount"
        case unseenByEndUserMessagesCount = "unseenByEndUserMessagesCount"
    }

    public init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        id = try values.decodeIfPresent(String.self, forKey: .id)
        channelId = try values.decodeIfPresent(String.self, forKey: .channelId)
        idOnExternalPlatform = try values.decodeIfPresent(String.self, forKey: .idOnExternalPlatform)
        ticketNumber = try values.decodeIfPresent(String.self, forKey: .ticketNumber)
        content = try values.decodeIfPresent(String.self, forKey: .content)
        title = try values.decodeIfPresent(String.self, forKey: .title)
        threadName = try values.decodeIfPresent(String.self, forKey: .threadName)
        url = try values.decodeIfPresent(String.self, forKey: .url)
        isOwn = try values.decodeIfPresent(Bool.self, forKey: .isOwn)
        createdAt = try values.decodeIfPresent(String.self, forKey: .createdAt)
        updatedAt = try values.decodeIfPresent(String.self, forKey: .updatedAt)
        author = try values.decodeIfPresent(Author.self, forKey: .author)
        image = try values.decodeIfPresent(String.self, forKey: .image)
        tagIds = try values.decodeIfPresent([String].self, forKey: .tagIds)
        likes = try values.decodeIfPresent(Int.self, forKey: .likes)
        attachments = try values.decodeIfPresent([String].self, forKey: .attachments)
        recipients = try values.decodeIfPresent([String].self, forKey: .recipients)
        canAddMoreMessages = try values.decodeIfPresent(Bool.self, forKey: .canAddMoreMessages)
        deletedOnExternalPlatform = try values.decodeIfPresent(Bool.self, forKey: .deletedOnExternalPlatform)
        unseenMessagesCount = try values.decodeIfPresent(Int.self, forKey: .unseenMessagesCount)
        unseenByUserMessagesCount = try values.decodeIfPresent(Int.self, forKey: .unseenByUserMessagesCount)
        unseenByEndUserMessagesCount = try values.decodeIfPresent(Int.self, forKey: .unseenByEndUserMessagesCount)
    }
}
struct OperationError : Codable {
    let errorCode: String
    let transactionId: String
    let errorMessage: String
}
    
extension OperationError: LocalizedError {
    var errorDescription: String? {
        return errorCode
    }
}
