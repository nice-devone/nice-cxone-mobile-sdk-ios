import Foundation


/// A textfield element which contains simple textfield or e-mail.
///
/// In case of e-mail, detectable with `isEmail` property, BE requires proper e-mail validation on the application side.
public struct CustomFieldTextField {
    
    /// The unique key identifier for the SDK contact custom fields sendable via ``ContactCustomFieldsProvider/set(_:for:)``.
    public let ident: String
    
    /// The title/placeholder for the textfield.
    public let label: String
    
    /// The actual value of the field; if exists.
    public let value: String?
    
    /// Determines if element is a simple text field or e-mail.
    public let isEmail: Bool
    
    let updatedAt: Date
}


// MARK: - Equatable

extension CustomFieldTextField: Equatable {
    
    public static func == (lhs: CustomFieldTextField, rhs: CustomFieldTextField) -> Bool {
        lhs.ident == rhs.ident
            && lhs.label == rhs.label
            && lhs.value == rhs.value
            && Calendar.current.compare(lhs.updatedAt, to: rhs.updatedAt, toGranularity: .second) == .orderedSame
            && lhs.isEmail == rhs.isEmail
    }
}
