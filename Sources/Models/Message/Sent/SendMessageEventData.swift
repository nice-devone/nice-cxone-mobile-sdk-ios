import Foundation

struct SendMessageEventData: Codable {
    public var thread: Thread
    public var messageContent: MessageContent
    public var idOnExternalPlatform: UUID
    public var consumer: CustomFieldsData
    public var consumerContact: CustomFieldsData
    public var attachments: [Attachment]
    public var browserFingerprint: BrowserFingerprint
    public var accessToken: AccessTokenPayload?
}
