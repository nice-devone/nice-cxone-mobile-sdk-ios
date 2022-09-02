import Foundation

struct SetContactCustomFieldsEventData: Codable {
    var thread: Thread
    var customFields: [CustomField]
    var consumerContact: ContactIdentifier
}
