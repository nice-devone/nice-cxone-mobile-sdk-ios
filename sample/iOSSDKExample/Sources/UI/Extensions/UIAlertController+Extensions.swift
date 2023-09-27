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
