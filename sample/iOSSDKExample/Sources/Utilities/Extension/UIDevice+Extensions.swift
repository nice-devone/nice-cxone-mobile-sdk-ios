import UIKit

extension UIDevice {

    var isPreview: Bool {
        ProcessInfo.processInfo.environment["XCODE_RUNNING_FOR_PREVIEWS"] == "1"
    }
    
    class var hasBottomSafeAreaInsets: Bool {
        let bottom = (UIApplication.shared.connectedScenes.first as? UIWindowScene)?.windows.last?.safeAreaInsets.bottom ?? 0
        
        return bottom > 0
    }
}
