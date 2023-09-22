import Foundation

/// A pre-chat survey field element which should be presented to user before chat thread is created.
public struct PreChatSurveyCustomField {
    
    /// Determines if it is necessary to fill out this custom field and send it via method ``ContactCustomFieldsProvider/set(_:for:)`` to the SDK.
    public let isRequired: Bool
    
    /// The type of element that can be present in the content of a dynamic pre-chat survey.
    public let type: CustomFieldType
}
