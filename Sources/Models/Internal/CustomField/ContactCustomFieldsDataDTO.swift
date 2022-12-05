import Foundation


/// Represents info abount data of a contact custom fields.
struct ContactCustomFieldsDataDTO: Codable {
    
    /// The actual contact custom fields data.
    let customFields: [CustomFieldDTO]
}
