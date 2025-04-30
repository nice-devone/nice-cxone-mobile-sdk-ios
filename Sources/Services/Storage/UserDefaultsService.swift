//
// Copyright (c) 2021-2025. NICE Ltd. All rights reserved.
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

class UserDefaultsService: NSObject {
    
    // MARK: - Keys
    
    enum Keys: String, CaseIterable {
        case welcomeMessage = "com.nice.cxonechat.welcomeMessage"
        case cachedThreadIdOnExternalPlatform = "com.nice.cxonechat.cachedThreadIdOnExternalPlatform"
        case visitorId = "com.nice.cxonechat.visitorId"
        case visitDetails = "com.nice.cxonechat.visitDetails"
    }
    
    // MARK: - Properties
    
    private static let suiteName = "CXoneChatSDK"
    
    static let shared = UserDefaultsService()
    
    private let userDefaults: UserDefaults?
    
    // MARK: - Init
    
    private override init() {
        self.userDefaults = UserDefaults(suiteName: Self.suiteName)
    }
    
    // MARK: - Static methods
    
    static func purge() {
        LogManager.trace("Removing all keys from UserDefaults")
        
        UserDefaultsService.shared.userDefaults?.removePersistentDomain(forName: Self.suiteName)
        
        UserDefaultsService.shared.userDefaults?.synchronize()
    }
    
    // MARK: - Methods
    
    func remove(_ key: Keys) {
        remove(key.rawValue)
    }
    
    func remove(_ key: String) {
        self.userDefaults?.removeObject(forKey: key)
        
        self.userDefaults?.synchronize()
    }
    
    func set<T: Encodable>(_ obj: T, for key: Keys) {
        set(obj, for: key.rawValue)
    }
    
    func set<T: Encodable>(_ obj: T, for key: String) {
        guard let data = try? JSONEncoder().encode(obj) else {
            return
        }
        
        self.userDefaults?.set(data, forKey: key)
        
        self.userDefaults?.synchronize()
    }
    
    func get<T: Decodable>(_ type: T.Type, for key: Keys) -> T? {
        get(T.self, for: key.rawValue)
    }
    
    func get<T: Decodable>(_ type: T.Type, for key: String) -> T? {
        guard let data = self.userDefaults?.object(forKey: key) as? Data else {
            return nil
        }
        
        return try? JSONDecoder().decode(T.self, from: data)
    }
}
