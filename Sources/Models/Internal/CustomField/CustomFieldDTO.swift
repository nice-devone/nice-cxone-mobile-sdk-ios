import Foundation


/// Represents all data about a single custom field.
struct CustomFieldDTO: Codable {

    // MARK: - Properties

    /// The key of the custom field data.
    let ident: String

    /// The actual value of the custom field.
    var value: String


    // MARK: - Init

    /// - Parameter ident: The key of the custom field data.
    /// - Parameter value: The actual value of the custom field.
    init(ident: String, value: String) {
        self.ident = ident
        self.value = value
    }
}
