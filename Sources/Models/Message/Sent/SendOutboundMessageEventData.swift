
import Foundation
struct SendOutboundMessageEventData: Codable {
    var thread: Thread
    var messageContent: MessageContent
    var idOnExternalPlatform: UUID
    var consumerContact: CustomFieldsData
    var attachments: [Attachment]
    var browserFingerprint: BrowserFingerprint
    var accessToken: AccessTokenPayload?
}
