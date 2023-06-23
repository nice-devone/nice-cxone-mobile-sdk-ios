import Foundation


/// The provider for customer chat fields related properties and methods.
public protocol CustomerCustomFieldsProvider {
    
    /// Custom fields for all chat threads.
    /// - Returns: Array of ustom fields for a customer.
    func get() -> [CustomFieldType]
    
    /// Custom fields for all chat threads.
    /// - Returns: Array of ustom fields for a customer.
    @available(*, deprecated, message: "This method has been replaced with `func get() -> [CustomFieldType]` in 1.1.0")
    func get() -> [String: String]
    
    /// Sets custom fields to be saved for a customer (persists across all threads involving the customer).
    /// - Parameter customFields: The custom fields to be saved.
    /// - Throws: ``CXoneChatError/notConnected`` if an attempt was made to use a method without connecting first.
    ///     Make sure you call the `connect` method first.
    /// - Throws: ``CXoneChatError/customerAssociationFailure`` if the SDK could not get customer identity and it may not have been set.
    /// - Throws: ``EncodingError.invalidValue(_:_:)`` if the given value is invalid in the current context for this format.
    func set(_ customFields: [String: String]) throws
}
