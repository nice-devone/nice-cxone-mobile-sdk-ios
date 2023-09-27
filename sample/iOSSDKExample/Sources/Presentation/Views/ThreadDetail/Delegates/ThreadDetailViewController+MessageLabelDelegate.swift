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

import MessageKit
import UIKit

extension ThreadDetailViewController: MessageLabelDelegate {
    
    func didSelectAddress(_ addressComponents: [String: String]) {
        Log.info("Address Selected: \(addressComponents)")
	}
	
    func didSelectDate(_ date: Date) {
        Log.info("Date Selected: \(date)")
	}
	
    func didSelectPhoneNumber(_ phoneNumber: String) {
        Log.info("Phone Number Selected: \(phoneNumber)")
	}
	
    func didSelectURL(_ url: URL) {
        Log.info("URL Selected: \(url)")
        
        present(WKWebViewController(url: url), animated: true)
	}
	
    func didSelectTransitInformation(_ transitInformation: [String: String]) {
        Log.info("TransitInformation Selected: \(transitInformation)")
	}

    func didSelectHashtag(_ hashtag: String) {
        Log.info("Hashtag selected: \(hashtag)")
	}

    func didSelectMention(_ mention: String) {
        Log.info("Mention selected: \(mention)")
	}

    func didSelectCustom(_ pattern: String, match: String?) {
        Log.info("Custom data detector patter selected: \(pattern)")
	}
}
