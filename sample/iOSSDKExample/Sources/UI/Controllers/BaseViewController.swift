import UIKit

class BaseViewController: UIViewController {
    
    override func motionEnded(_ motion: UIEvent.EventSubtype, with event: UIEvent?) {
        super.motionEnded(motion, with: event)
        
        guard motion == .motionShake else {
            return
        }
        
        let shareLogs = UIAlertAction(title: L10n.Debug.Logs.share, style: .default) { _ in
            do {
                self.present(try Log.getLogShareDialog(), animated: true)
            } catch {
                error.logError()
            }
        }
        let removeLogs = UIAlertAction(title: L10n.Debug.Logs.remove, style: .destructive) { _ in
            do {
                try Log.removeLogs()
            } catch {
                error.logError()
            }
        }
        let cancelAction = UIAlertAction(title: L10n.Common.cancel, style: .cancel)
        
        UIAlertController.show(.actionSheet, title: L10n.Debug.Logs.title, message: nil, actions: [shareLogs, removeLogs, cancelAction])
    }
}
