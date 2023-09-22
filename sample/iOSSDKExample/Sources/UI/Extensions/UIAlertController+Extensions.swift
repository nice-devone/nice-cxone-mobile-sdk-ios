import Foundation
import UIKit

/// Used for choosing which type of photo system we want to use when sending a message.
extension UIAlertController {
    
	static func show(
        _ style: UIAlertController.Style,
        title: String?,
        message: String?,
        actions: [UIAlertAction] = [UIAlertAction(title: "OK", style: .cancel, handler: nil)],
        completion: (() -> Void)? = nil
    ) {
		let alert = UIAlertController(title: title, message: message, preferredStyle: style)
        actions.forEach { alert.addAction($0) }
		
        guard let rootViewController = UIApplication.shared.rootViewController else {
            Log.error(CommonError.unableToParse("rootViewController"))
			return
		}
        
		rootViewController.present(alert, animated: true, completion: completion)
	}
}
