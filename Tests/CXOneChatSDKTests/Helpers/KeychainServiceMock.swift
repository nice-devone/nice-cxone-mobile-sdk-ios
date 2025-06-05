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

@testable import CXoneChatSDK
import Foundation
import KeychainSwift

class KeychainServiceMock: KeychainService {
    
    // MARK: - Properties
    
    private var data = [String: Data]()
    
    // MARK: - Methods
    
    override func purge() {
        data.removeAll()
    }
    
    override func get<T: Decodable>(_ type: T.Type, for key: KeychainService.Keys) -> T? {
        self.get(type, for: key.rawValue)
    }
    
    override func get<T: Decodable>(_ type: T.Type, for key: String) -> T? {
        guard let data = data[key] else {
            return nil
        }
        
        return try? JSONDecoder().decode(type, from: data)
    }
    
    override func set<T>(_ obj: T, for key: KeychainService.Keys) -> Bool where T : Encodable {
        set(obj, for: key.rawValue)
    }
    
    override func set<T>(_ obj: T, for key: String) -> Bool where T : Encodable {
        guard let object = try? JSONEncoder().encode(obj) else {
            return false
        }
        
        return data.updateValue(object, forKey: key) != nil
    }
}
