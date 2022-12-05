import Foundation


/// The provider for thread related properties and methods.
public protocol ChatThreadsProvider {
    
    /// The provider for message related properties and methods.
    var messages: MessagesProvider { get }
    
    /// The provider for chat fields related properties and methods.
    var customFields: ContactCustomFieldsProvider { get }
    
    /// The list of all chat threads.
    func get() -> [ChatThread]
    
    /// Creates a new thread by sending an initial message to the thread.
    /// - Warning: If attempted on a channel that only supports a single thread, this will fail once a thread is already created.
    /// - Returns: Returns `id` of a new created thread.
    func create() throws -> UUID
    
    /// Loads all of the threads for the current customer.
    /// - Warning: Should only be used on a channel configured for multiple threads.
    func load() throws
    
    /// Loads the a thread for the customer and gets messages.
    /// - Parameter id: The id of the thread to load. Optional, if omitted,
    ///     it will attempt to load the customer's active thread. If there is no active thread, this returns an error.
    func load(with id: UUID?) throws
    
    /// Loads information about the thread. This will provide the most recent message for the thread.
    /// - Parameter thread: The  thread to load.
    func loadInfo(for thread: ChatThread) throws
    
    /// Updates the name for a thread.
    /// - Parameters:
    ///   - name: The new name for the thread.
    ///   - id: The unique identifier of the thread to load.
    /// - Warning: Should only be used on a channel configured for multiple threads.
    func updateName(_ name: String, for id: UUID) throws
    
    /// Archives a thread from the list of all threads.
    /// - Parameter thread: The  thread to load.
    /// - Warning: Should only be used on a channel configured for multiple threads.
    func archive(_ thread: ChatThread) throws
    
    /// Reports that the most recent message of the specified thread was read by the customer.
    /// - Parameter thread: The  thread to load.
    func markRead(_ thread: ChatThread) throws
    
    /// Reports that the customer has started or finished typing in the specified chat thread.
    /// - parameter didStart: Indicator for start of finish typing.
    /// - parameter thread: The thread where typing was started.
    func reportTypingStart(_ didStart: Bool, in thread: ChatThread) throws
}
