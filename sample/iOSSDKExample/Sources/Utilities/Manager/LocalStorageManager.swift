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

import UIKit

struct LocalStorageManager {
    
    // MARK: - Keys
    
    enum Keys: String, CaseIterable {
        case configuration
        case chatNavigationBarLightColor
        case chatNavigationBarDarkColor
        case chatNavigationElementsLightColor
        case chatNavigationElementsDarkColor
        case chatBbackgroundLightColor
        case chatBackgroundDarkColor
        case chatAgentCellLightColor
        case chatAgentCellDarkColor
        case chatCustomerCellLightColor
        case chatCustomerCellDarkColor
        case chatAgentFontLightColor
        case chatAgentFontDarkColor
        case chatCustomerFontLightColor
        case chatCustomerFontDarkColor
    }
    
    // MARK: - Properties
    
    @Storage(key: .configuration)
    static var configuration: Configuration?
    
    @Storage(key: .chatNavigationBarLightColor)
    static var chatNavigationBarLightColor: UIColor?
    
    @Storage(key: .chatNavigationBarDarkColor)
    static var chatNavigationBarDarkColor: UIColor?
    
    @Storage(key: .chatNavigationElementsLightColor)
    static var chatNavigationElementsLightColor: UIColor?
    
    @Storage(key: .chatNavigationElementsDarkColor)
    static var chatNavigationElementsDarkColor: UIColor?
    
    @Storage(key: .chatBbackgroundLightColor)
    static var chatBbackgroundLightColor: UIColor?
    
    @Storage(key: .chatBackgroundDarkColor)
    static var chatBackgroundDarkColor: UIColor?
    
    @Storage(key: .chatAgentCellLightColor)
    static var chatAgentCellLightColor: UIColor?
    
    @Storage(key: .chatAgentCellDarkColor)
    static var chatAgentCellDarkColor: UIColor?
    
    @Storage(key: .chatCustomerCellLightColor)
    static var chatCustomerCellLightColor: UIColor?
    
    @Storage(key: .chatCustomerCellDarkColor)
    static var chatCustomerCellDarkColor: UIColor?
    
    @Storage(key: .chatAgentFontLightColor)
    static var chatAgentFontLightColor: UIColor?
    
    @Storage(key: .chatAgentFontDarkColor)
    static var chatAgentFontDarkColor: UIColor?
    
    @Storage(key: .chatCustomerFontLightColor)
    static var chatCustomerFontLightColor: UIColor?
    
    @Storage(key: .chatCustomerFontDarkColor)
    static var chatCustomerFontDarkColor: UIColor?
    
    // MARK: - Methods
    
    static func reset() {
        Keys.allCases.forEach { key in 
            UserDefaults.standard.removeObject(forKey: key.rawValue)
        }
        
        UserDefaults.standard.synchronize()
    }
}

// MARK: - Helpers

@propertyWrapper
struct Storage<T: Codable> {
    
    // MARK: - Properties
    
    private let key: LocalStorageManager.Keys
    private var cachedValue: T?
    
    var wrappedValue: T? {
        get {
            if let cachedValue {
                return cachedValue
            }
            
            guard let data = UserDefaults.standard.object(forKey: key.rawValue) as? Data else {
                return nil
            }
            
            do {
                return try JSONDecoder().decode(T.self, from: data)
            } catch {
                error.logError()
                
                return nil
            }
        }
        set {
            do {
                cachedValue = newValue
                
                if let newValue {
                    let data = try JSONEncoder().encode(newValue)
                    
                    UserDefaults.standard.set(data, forKey: key.rawValue)
                    UserDefaults.standard.synchronize()
                } else {
                    UserDefaults.standard.removeObject(forKey: key.rawValue)
                }
                
            } catch {
                error.logError()
            }
        }
    }
    
    // MARK: - Init
    
    init(key: LocalStorageManager.Keys) {
        self.key = key
    }
}
