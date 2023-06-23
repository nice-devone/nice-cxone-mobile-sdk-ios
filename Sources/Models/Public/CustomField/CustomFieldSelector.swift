import Foundation


/// A list/selector element type. It contains list of options which are selected via dropdown picker, table or related UI element.
public struct CustomFieldSelector {
    
    /// The unique key identifier for the SDK contact custom fields sendable via ``ContactCustomFieldsProvider/set(_:for:)``.
    public let ident: String
    
    /// The title/placeholder for the textfield.
    public let label: String
    
    /// The actual value of the custom field; if exists.
    public let value: String?
    
    /// Key-value pairs with selector options.
    ///
    /// Key represents a value identifier on the backend side and value is used as a label in the application UI component.
    /// Integration application has to send value identifier instead of its real value because value might change.
    public let options: [String: String]
    
    let updatedAt: Date
}


// MARK: - Equatable

extension CustomFieldSelector: Equatable {
    
    public static func == (lhs: CustomFieldSelector, rhs: CustomFieldSelector) -> Bool {
        lhs.ident == rhs.ident
            && lhs.label == rhs.label
            && lhs.value == rhs.value
            && lhs.options == rhs.options
            && Calendar.current.compare(lhs.updatedAt, to: rhs.updatedAt, toGranularity: .second) == .orderedSame
    }
}
