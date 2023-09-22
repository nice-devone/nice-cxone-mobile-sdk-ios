import Foundation

/// Complex type with subelements represented as a multi-root tree data structure.
///
/// UI element, on the application side, should present nodes as a nested list
/// and send picker ``nodes`` element's value; if necessary.
public struct CustomFieldHierarchical {
    
    /// The unique key identifier for the SDK contact custom fields sendable via ``ContactCustomFieldsProvider/set(_:for:)``
    /// and selected ``PrechatSurveyNode/value`` from the ``nodes``.
    public let ident: String
    
    /// The title/placeholder for the textfield.
    public let label: String
    
    /// The actual value of the field; if exists.
    public let value: String?
    
    /// The multi-root tree nodes.
    public let nodes: [CustomFieldHierarchicalNode]
    
    let updatedAt: Date
}

// MARK: - Equatable

extension CustomFieldHierarchical: Equatable {
    
    public static func == (lhs: CustomFieldHierarchical, rhs: CustomFieldHierarchical) -> Bool {
        lhs.ident == rhs.ident
            && lhs.label == rhs.label
            && lhs.value == rhs.value
            && lhs.nodes == rhs.nodes
            && Calendar.current.compare(lhs.updatedAt, to: rhs.updatedAt, toGranularity: .second) == .orderedSame
    }
}
