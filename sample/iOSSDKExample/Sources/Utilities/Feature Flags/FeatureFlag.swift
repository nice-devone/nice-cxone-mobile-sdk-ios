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

/// Runtime feature flags defined in the bundle file..
///
/// Features, which are correctly defined in the `Settings.bundle` file and added as a case to the FeatureFlag manager,
/// appear in the native Settings application and those feature can be changed without editing single line of code.
/// Apple docs: https://developer.apple.com/library/archive/documentation/Cocoa/Conceptual/UserDefaults/Preferences/Preferences.html
///
/// Steps to create a feature flag:
/// - add `Toggle Switch` row to the `Root.plist` in the `Settings.bundle`.
/// - add new case to the `FeatureFlag` manager  with same identifier of the added feature flag in the `Root.plist`.
///
/// Usage:
/// ```swift
/// if FeatureFlag.enableFeature.isActive {
///     ...
/// } else {
///     ...
/// }
/// ```
/// - Warning: Feature Flag manager is handling  only `Toggle Switch`. Rest of types (Textfield, Slider, Title, ...) are not supported.
enum FeatureFlag: String {
    
    // MARK: - Debug Features
    
    case enableDebugButtonInConfig
    
    // MARK: - Properties
    
    var isActive: Bool {
        UserDefaults.standard.bool(forKey: self.rawValue)
    }
    
    // MARK: - Methods
    
    static func registerFeatureFlags() {
        let defaultsToRegister = [String: AnyObject]()
        UserDefaults.standard.register(defaults: defaultsToRegister)
    }
}
