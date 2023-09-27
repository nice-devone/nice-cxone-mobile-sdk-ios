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
