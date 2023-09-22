import Foundation

/// The provider for chat fields related properties and methods.
public protocol ContactCustomFieldsProvider {
    
    /// Custom fields for current chat case.
    ///
    /// - Parameter threadId: The unique identifier of the thread for the custom fields.
    /// - Returns: Array of custom fields for current chat case.
    func get(for threadId: UUID) -> [CustomFieldType]
    
    /// Sets custom fields to be saved on a contact (specific thread).
    /// - Parameters:
    ///   - customFields: The custom fields to be saved.
    ///   - threadId: The unique identifier of the thread for the custom fields.
    /// - Throws: ``CXoneChatError/notConnected`` if an attempt was made to use a method without connecting first.
    ///     Make sure you call the `connect` method first.
    /// - Throws: ``CXoneChatError/customerAssociationFailure`` if the SDK could not get customer identity and it may not have been set.
    /// - Throws: ``EncodingError.invalidValue(_:_:)`` if the given value is invalid in the current context for this format.
    func set(_ customFields: [String: String], for threadId: UUID) throws
}
