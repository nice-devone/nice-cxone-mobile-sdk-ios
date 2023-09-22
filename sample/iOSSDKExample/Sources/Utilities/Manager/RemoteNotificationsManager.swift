import CXoneChatSDK
import UIKit
import UserNotifications

class RemoteNotificationsManager: NSObject {
    
    // MARK: - Properties
    
    static let shared = RemoteNotificationsManager()
    
    private lazy var notificationCenter: UNUserNotificationCenter = .current()
    
    var isChatSDKActive = false
    
    var onRegistrationFinished: (() -> Void)?
    
    // MARK: - Init
    
    private override init() {
        super.init()
    }
    
    // MARK: - Methods
    
    func unregister() {
        Log.trace("Unregisterring for remote notifications")
        
        Task { @MainActor in
            UIApplication.shared.unregisterForRemoteNotifications()
        }
    }
    
    func registerIfNeeded() {
        notificationCenter.getNotificationSettings { [weak self] settings in
            if settings.authorizationStatus == .notDetermined {
                self?.notificationCenter.requestAuthorization(options: [.alert, .badge, .sound]) { (success, error) in
                    error?.logError()
                    
                    guard success else {
                        Log.error("requestAuthorization failed")
                        
                        self?.onRegistrationFinished?()
                        return
                    }
                    
                    Task { @MainActor in
                        UIApplication.shared.registerForRemoteNotifications()
                    }
                }
            } else if settings.authorizationStatus == .denied {
                Log.warning(.failed("Notification permission was previously denied, go to settings & privacy to re-enable"))
                
                self?.onRegistrationFinished?()
            } else if settings.authorizationStatus == .authorized {
                Task { @MainActor in
                    UIApplication.shared.registerForRemoteNotifications()
                }
            }
        }
    }
}
