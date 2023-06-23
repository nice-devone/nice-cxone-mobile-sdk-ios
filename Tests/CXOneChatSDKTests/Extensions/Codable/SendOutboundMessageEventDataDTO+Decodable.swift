@testable import CXoneChatSDK
import Foundation


extension SendOutboundMessageEventDataDTO: Decodable {
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let accessTokenContainer = try? container.nestedContainer(keyedBy: AccessTokenCodingKey.self, forKey: .accessToken)
        let contactCustomFieldsContainer = try container.nestedContainer(keyedBy: ContactCustomFieldsCodingKey.self, forKey: .contact)
        
        self.init(
            thread: try container.decode(ThreadDTO.self, forKey: .thread),
            contentType: try container.decode(MessageContentDTOType.self, forKey: .messageContent),
            idOnExternalPlatform: try container.decode(UUID.self, forKey: .idOnExternalPlatform),
            contactCustomFields: try contactCustomFieldsContainer.decode([CustomFieldDTO].self, forKey: .customFields),
            attachments: try container.decode([AttachmentDTO].self, forKey: .attachments),
            deviceFingerprint: try container.decode(DeviceFingerprintDTO.self, forKey: .deviceFingerprint),
            token: try accessTokenContainer?.decodeIfPresent(String.self, forKey: .token)
        )
    }
}
