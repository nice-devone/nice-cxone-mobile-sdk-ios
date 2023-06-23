import Foundation


/// A single element of the ``PreChatSurveyHierarchical/nodes`` represented as a tree data structure.
public struct CustomFieldHierarchicalNode {
    
    /// The value for the contact custom fields.
    ///
    /// Send in combination of ``PreChatSurveyHierarchical/ident`` via ``ContactCustomFieldsProvider/set(_:for:)`` method.
    public let value: String
    
    /// The text for UI element which represents its value.
    ///
    /// - Warning: Dont send this property as a value of ``ContactCustomFieldsProvider/set(_:for:)``.
    /// It only readable representation of its actual ``value``.
    public let label: String
    
    /// The tree leaves; if any exists.
    public let children: [CustomFieldHierarchicalNode]
}


// MARK: - Equatable

extension CustomFieldHierarchicalNode: Equatable {
    
    public static func == (lhs: CustomFieldHierarchicalNode, rhs: CustomFieldHierarchicalNode) -> Bool {
        lhs.value == rhs.value
            && lhs.label == rhs.label
            && lhs.value == rhs.value
            && lhs.children == rhs.children
    }
}
