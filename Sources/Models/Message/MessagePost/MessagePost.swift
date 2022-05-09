//
//  Created by Customer Dynamics Development on 9/22/21.
//

import Foundation
import UIKit

public struct Attachment {
	public var url: String
	public var friendlyName: String
	
	public init(url: String, friendlyName: String) {
		self.url = url
		self.friendlyName = friendlyName
	}
}
extension Attachment: Codable {}

public struct Brand {
	public var id: Int

	public init(id: Int) {
		self.id = id
	}
}
extension Brand: Codable {}

public struct Channel {
	public var id: String

	public init(id: String) {
		self.id = id
	}
}
extension Channel: Codable {}

public struct CustomerFields {
	public var customFields: [CustomField]

	public init(customFields : [CustomField]) {
		self.customFields = customFields
	}
}
extension CustomerFields: Codable {}

public struct CustomField {
	public var ident: String
	public var value: String
	
	public init(ident: String, value: String) {
		self.ident = ident
		self.value = value
	}
}
extension CustomField : Codable {}

public struct MessageContent {
	public var type: String
	public var payload: MessagePayload
	
	public init(type: String, payload: MessagePayload) {
		self.type = type
		self.payload = payload
	}
}
extension MessageContent: Codable {}

public struct MessagePayload {
	public var text: String
	public var elements: [MessagePayloadElement]
	
	public init(text: String, elements: [MessagePayloadElement]) {
		self.text = text
		self.elements = elements
	}
}
extension MessagePayload: Codable {}

public struct MessageThreadCodable {
	public var idOnExternalPlatform: UUID
	public var threadName: String
	
	public init(idOnExternalPlatform: UUID, threadName: String) {
		self.idOnExternalPlatform = idOnExternalPlatform
		self.threadName = threadName
	}
}
extension MessageThreadCodable: Codable {}

public struct ThreadCodable {
	public var id: String
    public init(id: String) {
        self.id = id
    }
}
extension ThreadCodable: Codable {}

public struct MessagePayloadElement {
	public var id: String
	public var type: String
	public var text: String
	public var postback: String
	public var url: String
	public var elements: [MessageElement]
}
extension MessagePayloadElement: Codable {}

public struct MessageElement {
	public var id: String?
	public var type: String?
	public var text: String?
	public var postback: String?
	public var url: String?
	public var fileName: String?
	public var mimeType: String?
}
extension MessageElement: Codable {}

public struct BrowserFingerprint {
    var browser = ""
    var browserVersion = ""
    var country = ""
    var ip = ""
    var language = ""
    var location = ""
    var os = "iOS"
    var osVersion = UIDevice.current.systemVersion
    var deviceType = "mobile"
    public var deviceToken = ""
}
extension BrowserFingerprint: Codable {}
