//
// Copyright (c) 2021-2023. NICE Ltd. All rights reserved.
//
// Licensed under the NICE License;
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//    https://github.com/nice-devone/nice-cxone-mobile-sdk-ios/blob/main/LICENSE
//
// TO THE EXTENT PERMITTED BY APPLICABLE LAW, THE CXONE MOBILE SDK IS PROVIDED ON
// AN “AS IS” BASIS. NICE HEREBY DISCLAIMS ALL WARRANTIES AND CONDITIONS, EXPRESS
// OR IMPLIED, INCLUDING (WITHOUT LIMITATION) WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE, NON-INFRINGEMENT, AND TITLE.
//

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
