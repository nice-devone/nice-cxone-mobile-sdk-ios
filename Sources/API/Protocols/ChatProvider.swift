import Foundation


/// The interface for interacting with chat features of the CXone platform.
public protocol ChatProvider {
    
    /// The version of the CXone chat SDK.
    static var version: String { get }
    
    /// The singleton instance of the CXone chat SDK.
    static var shared: ChatProvider { get set }
    
    /// The handler for the logs occured in CXone chat.
    var logDelegate: LogDelegate? { get set }
    
    /// The handler for the chat events.
    var delegate: CXoneChatDelegate? { get set }
    
    /// The provider for connection related properties and methods.
    var connection: ConnectionProvider { get }
    
    /// The provider for customer related properties and methods.
    var customer: CustomerProvider { get }
    
    /// The provider for customer chat fields related properties and methods.
    var customerCustomFields: CustomerCustomFieldsProvider { get }
    
    /// The provider for thread related properties and methods.
    var threads: ChatThreadsProvider { get }
    
    /// The provider for report related properties and methods.
    var analytics: AnalyticsProvider { get }
    
    /// Configures internal logger to be able to detect errors, warnings or even trace chat flow.
    ///
    /// - Parameters:
    ///   - level: Specifies level of records to be presented in the console. Lower levels are ignored.
    ///   - verbository: Specifies verbosity of information in the log record.
    static func configureLogger(level: LogManager.Level, verbosity: LogManager.Verbosity)
    
    /// Signs the customer out and disconnects from the CXone service.
    static func signOut()
}
