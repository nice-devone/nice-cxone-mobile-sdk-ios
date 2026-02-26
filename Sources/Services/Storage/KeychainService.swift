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
import KeychainSwift

class KeychainService: KeychainSwift {
    
    // MARK: - Keys
    
    enum Keys: String, CaseIterable {
        case customer = "com.nice.cxonechat.customer"
        case accessToken = "com.nice.cxonechat.accessToken"
        case transactionToken = "com.nice.cxonechat.transactionToken"
    }
    
    // MARK: - Methods
    
    func purge() {
        LogManager.trace("Removing all keys from Keychain")
        
        Keys.allCases.forEach {
            delete($0.rawValue)
        }
    }

    @discardableResult
    func set<T: Encodable>(_ obj: T, for key: Keys) -> Bool {
        set(obj, for: key.rawValue)
    }
    
    @discardableResult
    func set<T: Encodable>(_ obj: T, for key: String) -> Bool {
        guard let data = try? JSONEncoder().encode(obj) else {
            LogManager.error(CXoneChatError.invalidData)
            return false
        }
        
        return set(data, forKey: key)
    }
    
    func get<T: Decodable>(_ type: T.Type, for key: Keys) -> T? {
        get(T.self, for: key.rawValue)
    }
    
    func get<T: Decodable>(_ type: T.Type, for key: String) -> T? {
        guard let data = getData(key) else {
            return nil
        }
        
        return try? JSONDecoder().decode(T.self, from: data)
    }
}
