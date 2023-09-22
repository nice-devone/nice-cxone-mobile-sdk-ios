import UIKit

extension UIApplication {
    
    // MARK: - Static Properties
    
    static var isDarkModeActive: Bool {
        UITraitCollection.current.userInterfaceStyle == .dark
    }
    
    // MARK: - Properties
    
    var mainWindow: UIWindow? {
        UIApplication.shared.windows.filter(\.isKeyWindow).first
    }
    
    var rootViewController: UIViewController? {
        (connectedScenes.first as? UIWindowScene)?.windows.last?.rootViewController
    }
    
    var currentController: UIViewController? {
        guard let rootController = rootViewController else {
            return nil
        }
        
        var currentController = rootController
        while currentController.presentedViewController != nil {
            guard let presentedViewController = currentController.presentedViewController else {
                break
            }
            
            currentController = presentedViewController
        }
        
        return currentController
    }
}
