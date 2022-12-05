import Foundation
import KeychainSwift
import UIKit


/// The implementation of the interface for interacting with chat features of the CXone platform.
public class CXoneChat: ChatProvider {
    
    // MARK: - Static properties
    
    public static var shared: ChatProvider = CXoneChat(socketService: .init(keychainSwift: .init(), session: .shared))
    
    
    // MARK: - Public properties
    
    public weak var delegate: CXoneChatDelegate? {
        didSet {
            (threads as? ChatThreadsService)?.delegate = delegate
            socketDelegateManager.delegate = delegate
        }
    }
    
    public weak var logDelegate: LogDelegate? {
        get { LogManager.delegate }
        set { LogManager.delegate = newValue }
    }
    
    
    // MARK: - API providers
    
    public lazy var connection: ConnectionProvider = resolver.resolve()
    public lazy var customer: CustomerProvider = resolver.resolve()
    public lazy var customerCustomFields: CustomerCustomFieldsProvider = resolver.resolve()
    public lazy var threads: ChatThreadsProvider = resolver.resolve()
    public lazy var analytics: AnalyticsProvider = resolver.resolve()
    
    
    // MARK: - Internal properties
    
    let socketDelegateManager: SocketDelegateManager
    
    
    // MARK: - Private properties
    
    private let resolver: DependencyManager
    
    
    // MARK: - Init
    
    init(socketService: SocketService) {
        self.resolver = DependencyManager(socketService: socketService)
        self.socketDelegateManager = resolver.resolve()
    }
    
    
    // MARK: - Static methods
    
    public static func signOut() {
        LogManager.trace("Signing out a user.")
        
        KeychainSwift().clear()
        UserDefaults.standard.removeObject(forKey: "cxOneHasRun")
        UserDefaults.standard.removeObject(forKey: "welcomeMessage")
        shared = CXoneChat(socketService: .init(keychainSwift: .init(), session: .shared))
    }
    
    public static func configureLogger(level: LogManager.Level, verbosity: LogManager.Verbosity) {
        LogManager.configure(level: level, verbosity: verbosity)
    }
}
