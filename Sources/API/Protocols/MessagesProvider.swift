import Foundation


/// The provider for message related properties and methods.
public protocol MessagesProvider {
    
    /// Loads additional messages in the specified thread.
    /// - parameter chatThread: The thread for which to load more messages.
    func loadMore(for chatThread: ChatThread) throws
    
    /// Sends a message in the specified chat thread through CXone chat.
    /// - Parameters:
    ///   - message: The message text to send.
    ///   - chatThread: The thread in which the message is to be sent.
    func send(_ message: String, for chatThread: ChatThread) async throws
    
    /// Sends a message with attachments in the current thread through CXone chat.
    /// - Parameters:
    ///   - message: The message text to send along with the attachments (optional).
    ///   - attachments: The attachments to send.
    ///   - chatThread: The thread in which the message and attachments are to be sent.
    func send(_ message: String, with attachments: [AttachmentUpload], for chatThread: ChatThread) async throws
}
