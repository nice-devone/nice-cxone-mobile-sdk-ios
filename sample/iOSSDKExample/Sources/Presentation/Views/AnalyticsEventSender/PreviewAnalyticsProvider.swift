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

import CXoneChatSDK
import Foundation

class PreviewAnalyticsProvider: AnalyticsProvider {
    
    // MARK: - Properties
    
    var visitorId: UUID?

    // MARK: - Methods
    
    func viewPage(title: String, url: String) throws { }

    func viewPageEnded(title: String, url: String) throws { }

    func chatWindowOpen() throws { }

    func visit() throws { }

    func conversion(type: String, value: Double) throws { }

    func proactiveActionDisplay(data: CXoneChatSDK.ProactiveActionDetails) throws { }

    func proactiveActionClick(data: CXoneChatSDK.ProactiveActionDetails) throws { }

    func proactiveActionSuccess(_ isSuccess: Bool, data: CXoneChatSDK.ProactiveActionDetails) throws { }

    func customVisitorEvent(data: CXoneChatSDK.VisitorEventDataType) throws { }
}
