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

final class UserDefaultsServiceImpl {
    
    // MARK: - Properties
    
    private static let suiteName = "CXoneChatSDK"
    
    private let userDefaults: UserDefaults?
    private let encoder = JSONEncoder()
    private let decoder = JSONDecoder()
    private let suiteName: String
    
    // MARK: - Init
    
    init(suiteName: String = UserDefaultsServiceImpl.suiteName) {
        self.userDefaults = UserDefaults(suiteName: suiteName)
        self.suiteName = suiteName
    }
}

// MARK: - UserDefaultsService

extension UserDefaultsServiceImpl: UserDefaultsService {
    
    func remove(_ key: String) {
        self.userDefaults?.removeObject(forKey: key)
        
        self.userDefaults?.synchronize()
    }
    
    func set<T: Encodable>(_ obj: T?, for key: String) {
        defer {
            self.userDefaults?.synchronize()
        }
        
        do {
            guard let obj else {
                throw CXoneChatError.missingParameter("obj")
            }
            
            self.userDefaults?.set(try encoder.encode(obj), forKey: key)
        } catch {
            self.userDefaults?.removeObject(forKey: key)
        }
    }
    
    func get<T: Decodable>(_ type: T.Type, for key: String) -> T? {
        guard let data = self.userDefaults?.data(forKey: key) else {
            return nil
        }
        
        do {
            return try decoder.decode(T.self, from: data)
        } catch {
            return nil
        }
    }
    
    func purge() {
        LogManager.trace("Removing all keys from UserDefaults")
        
        userDefaults?.removePersistentDomain(forName: suiteName)
        
        userDefaults?.synchronize()
    }
}
