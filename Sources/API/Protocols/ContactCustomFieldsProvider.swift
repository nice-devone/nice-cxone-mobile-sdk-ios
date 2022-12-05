import Foundation


/// The provider for chat fields related properties and methods.
public protocol ContactCustomFieldsProvider {
    
    /// Sets custom fields to be saved on a contact (specific thread).
    /// - Parameters:
    ///   - customFields: The custom fields to be saved.
    ///   - threadId: The unique identifier of the thread for the custom fields.
    func set(_ customFields: [String: String], for threadId: UUID) throws
    
    /// Custom fields for current chat case.
    ///
    ///  - Parameter threadId: The unique identifier of the thread for the custom fields.
    ///  - Returns: Array of custom fields for current chat case.
    func get(for threadId: UUID) -> [String: String]
}
