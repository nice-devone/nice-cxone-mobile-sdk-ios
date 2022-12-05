import Foundation


/// The provider for customer chat fields related properties and methods.
public protocol CustomerCustomFieldsProvider {
    
    /// Custom fields for all chat threads.
    /// - Returns: Array of ustom fields for a customer.
    func get() -> [String: String]
    
    /// Sets custom fields to be saved for a customer (persists across all threads involving the customer).
    /// - Parameter customFields: The custom fields to be saved.
    func set(_ customFields: [String: String]) throws
}
