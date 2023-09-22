import Foundation

/// A definition of the pre-chat form which should be answered by the user before the new thread is created.
public struct PreChatSurvey {
    
    /// The name of the dynamic pre-chat survey.
    public let name: String
    
    /// An array of pre-chat survey fields which should be presented to user before chat thread is created.
    public let customFields: [PreChatSurveyCustomField]
}
