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
import IQKeyboardManagerSwift
#if HasLWA
    import LoginWithAmazon
#endif
import UIKit

@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    // MARK: - Properties
    
    var window: UIWindow?
    private var appModule: AppModule?
    private var loginCoordinator: LoginCoordinator?
    private var deeplinkOption: DeeplinkOption?
   
    // MARK: - Methods
    
    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {
        print("===== SESSION STARTED =====")

        #if HasLWA
        LoginWithAmazonAuthenticator.initialize()
        #endif
        
        // Register feature flags defined in the `Root.plist` of the `Settings.bundle`
        FeatureFlag.registerFeatureFlags()
        
        // Setup local Log manager
        Log.isEnabled = true
        Log.isWriteToFileEnabled = true
        
        // Setup CXoneChat SDK Log manager
        CXoneChat.configureLogger(level: .trace, verbosity: .full)
        CXoneChat.shared.logDelegate = self
        
        // Setup Keyboard manager
        IQKeyboardManager.shared.enable = true
        IQKeyboardManager.shared.disabledDistanceHandlingClasses.append(ThreadDetailViewController.self)
        
        // Reset Badge Number
        UIApplication.shared.applicationIconBadgeNumber = 0
        
        // Setup User Notification Center for real device
        UNUserNotificationCenter.current().delegate = self
        
        window = UIWindow(frame: UIScreen.main.bounds)
        
        let navigationController = UINavigationController()
        window?.rootViewController = navigationController
        window?.makeKeyAndVisible()
        
        self.loginCoordinator = LoginCoordinator(navigationController: navigationController)
        // swiftlint:disable:next force_unwrapping
        self.appModule = AppModule(coordinator: loginCoordinator!)
        loginCoordinator?.assembler = appModule?.assembler
        
        loginCoordinator?.start(with: deeplinkOption)
        
        return true
    }
    
    func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey: Any] = [:]) -> Bool {
        if ThreadsDeeplinkHandler.canOpenUrl(url) {
            CXoneChat.shared.connection.disconnect()
            
            self.deeplinkOption = ThreadsDeeplinkHandler.handleUrl(url)
            loginCoordinator?.start(with: deeplinkOption)
            
            return true
        } else if let authenticator = OAuthenticatorsManager.authenticator {
            return authenticator.handleOpen(url: url, sourceApplication: options[UIApplication.OpenURLOptionsKey.sourceApplication] as? String)
        } else {
            return false
        }
    }
    
    func application(
        _ application: UIApplication,
        shouldAllowExtensionPointIdentifier extensionPointIdentifier: UIApplication.ExtensionPointIdentifier
    ) -> Bool {
        extensionPointIdentifier != .keyboard
    }
}

// MARK: - UNUserNotificationCenterDelegate

extension AppDelegate: UNUserNotificationCenterDelegate {
    
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        CXoneChat.shared.customer.setDeviceToken(deviceToken)
        
        RemoteNotificationsManager.shared.onRegistrationFinished?()
    }
    
    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        error.logError()
        
        RemoteNotificationsManager.shared.onRegistrationFinished?()
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification) async -> UNNotificationPresentationOptions {
        if RemoteNotificationsManager.shared.isChatSDKActive {
            return []
        } else {
            UIApplication.shared.applicationIconBadgeNumber += 1
            
            return [.alert, .badge, .sound]
        }
    }
    
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable: Any]) async -> UIBackgroundFetchResult {
        guard let aps = userInfo["aps"] as? NSDictionary,
              let alert = aps["alert"] as? NSDictionary,
              let deeplink = alert["deeplink"] as? String,
              let url = URL(string: deeplink)
        else {
            return .noData
        }
        
        UIApplication.shared.applicationIconBadgeNumber = 0
        
        if ThreadsDeeplinkHandler.canOpenUrl(url) {
            CXoneChat.shared.connection.disconnect()
            
            self.deeplinkOption = ThreadsDeeplinkHandler.handleUrl(url)
            loginCoordinator?.start(with: deeplinkOption)
        }
        
        return .noData
    }
}

// MARK: - LogDelegate

extension AppDelegate: LogDelegate {
    
    func logError(_ message: String) {
        Log.message("[SDK] \(message)")
    }
    
    func logWarning(_ message: String) {
        Log.message("[SDK] \(message)")
    }
    
    func logInfo(_ message: String) {
        Log.message("[SDK] \(message)")
    }
    
    func logTrace(_ message: String) {
        Log.message("[SDK] \(message)")
    }
}
