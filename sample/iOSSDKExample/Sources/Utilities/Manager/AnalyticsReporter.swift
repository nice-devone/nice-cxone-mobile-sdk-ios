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
import UIKit

class AnalyticsReporter {
    
    // MARK: - Properties
    
    private let analyticsTitle: String
    private let analyticsUrl: String
    
    // MARK: - Lifecycle
    
    init(analyticsTitle: String, analyticsUrl: String) {
        self.analyticsTitle = analyticsTitle
        self.analyticsUrl = analyticsUrl
        
        NotificationCenter.default.addObserver(self, selector: #selector(onViewDidAppear), name: UIApplication.willEnterForegroundNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(didEnterBackground), name: UIApplication.didEnterBackgroundNotification, object: nil)
    }
    
    deinit {
        onDisappear()
    }
    
    // MARK: - Methods
    
    func onAppear() {
        onViewDidAppear()
    }
    
    func onDisappear() {
        NotificationCenter.default.removeObserver(self, name: UIApplication.willEnterForegroundNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIApplication.didEnterBackgroundNotification, object: nil)
	}

    func reportViewPage() {
        onViewDidAppear()
    }
}

// MARK: - Private methods

private extension AnalyticsReporter {
    
    @objc
    func didEnterBackground() {
        guard !analyticsTitle.isEmpty, !analyticsUrl.isEmpty else {
            fatalError("Title or Uri has not been set correctly")
        }
        
        Task {
            do {
                try await CXoneChat.shared.analytics.viewPageEnded(title: analyticsTitle, url: analyticsUrl)
            } catch {
                error.logError()
            }
        }
    }
    
    @objc
    func onViewDidAppear() {
        guard !analyticsTitle.isEmpty, !analyticsUrl.isEmpty else {
            fatalError("Title or Uri has not been set correctly")
        }
        
        Task {
            do {
                try await CXoneChat.shared.analytics.viewPage(title: analyticsTitle, url: analyticsUrl)
            } catch {
                error.logError()
            }
        }
    }
}
