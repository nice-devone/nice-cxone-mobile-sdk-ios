//
// Copyright (c) 2021-2026. NICE Ltd. All rights reserved.
//
// Licensed under the NICE License;
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//    https://github.com/nice-devone/nice-cxone-mobile-sdk-ios/blob/main/LICENSE
//
// TO THE EXTENT PERMITTED BY APPLICABLE LAW, THE CXONE MOBILE SDK IS PROVIDED ON
// AN "AS IS" BASIS. NICE HEREBY DISCLAIMS ALL WARRANTIES AND CONDITIONS, EXPRESS
// OR IMPLIED, INCLUDING (WITHOUT LIMITATION) WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE, NON-INFRINGEMENT, AND TITLE.
//

protocol UserDefaultsService: Sendable {
    func purge()
    func remove(_ key: String)
    func set<T: Encodable>(_ obj: T?, for key: String)
    func get<T: Decodable>(_ type: T.Type, for key: String) -> T?
}

// MARK: - Keys

enum UserDefaultKeys: String, CaseIterable {
    case welcomeMessage = "com.nice.cxonechat.welcomeMessage"
    case cachedThreadIdOnExternalPlatform = "com.nice.cxonechat.cachedThreadIdOnExternalPlatform"
    case visitorId = "com.nice.cxonechat.visitorId"
    case visitDetails = "com.nice.cxonechat.visitDetails"
    /// Sentinel marking that a marker-aware SDK version has run at least once on this installation.
    ///
    /// UserDefaults is wiped when the app is uninstalled, so this marker's absence means either a
    /// genuine fresh install or the first launch after upgrading from a pre-marker SDK version. The
    /// two are told apart by the stored identity fingerprint before purging keychain data that may
    /// have survived an uninstall (see ``ConnectionContextImpl``).
    case installationMarker = "com.nice.cxonechat.installationMarker"
}

// MARK: - Helpers

extension UserDefaultsService {
    
    func remove(_ key: UserDefaultKeys) {
        remove(key.rawValue)
    }
    
    func get<T: Decodable>(_ type: T.Type, for key: UserDefaultKeys) -> T? {
        get(T.self, for: key.rawValue)
    }
    
    func set<T: Encodable>(_ obj: T?, for key: UserDefaultKeys) {
        set(obj, for: key.rawValue)
    }
}
