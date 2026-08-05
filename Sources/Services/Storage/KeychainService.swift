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

import Foundation
import KeychainSwift

/// Abstraction over the keychain backing store. Using a protocol (instead of
/// inheritance) lets tests swap in an in-memory mock without needing `open`
/// access on the concrete `KeychainService`.
protocol KeychainStorage: Sendable {

    func purge()

    @discardableResult
    func set<T: Encodable>(_ obj: T, for key: KeychainService.Keys) -> Bool

    @discardableResult
    func set<T: Encodable>(_ obj: T, for key: String) -> Bool

    func get<T: Decodable>(_ type: T.Type, for key: KeychainService.Keys) -> T?

    func get<T: Decodable>(_ type: T.Type, for key: String) -> T?
}

/// `@unchecked Sendable` is required here because the superclass `KeychainSwift`
/// is an external type that predates Swift's `Sendable` annotations. The subclass
/// is still safe to share across isolation domains because:
///
///   1. The underlying `Security.framework` keychain APIs (`SecItemAdd`,
///      `SecItemCopyMatching`, `SecItemDelete`) are documented thread-safe.
///   2. `KeychainSwift`'s own stored properties (`prefix`, `accessGroup`,
///      `synchronizable`, etc.) are configuration set at init and never mutated
///      by `KeychainService`.
///   3. This subclass adds no mutable state.
///
/// Remove this annotation once `KeychainSwift` ships a formal `Sendable`
/// conformance.
final class KeychainService: KeychainSwift, KeychainStorage, @unchecked Sendable {

    // MARK: - Keys

    enum Keys: String, CaseIterable {
        case customer = "com.nice.cxonechat.customer"
        case transactionToken = "com.nice.cxonechat.transactionToken"
    }
    
    // MARK: - Properties

    private let encoder = JSONEncoder()
    private let decoder = JSONDecoder()

    // MARK: - Methods

    func purge() {
        LogManager.trace("Removing all keys from Keychain")

        Keys.allCases.forEach { key in
            do {
                try delete(key.rawValue)
            } catch {
                LogManager.warning("Failed to delete keychain key \(key.rawValue): \(error)")
            }
        }
    }

    @discardableResult
    func set<T: Encodable>(_ obj: T, for key: Keys) -> Bool {
        set(obj, for: key.rawValue)
    }

    @discardableResult
    func set<T: Encodable>(_ obj: T, for key: String) -> Bool {
        guard let data = try? encoder.encode(obj) else {
            LogManager.error(CXoneChatError.invalidData)
            return false
        }

        do {
            try set(data, forKey: key)
            return true
        } catch {
            LogManager.error(error)
            return false
        }
    }

    func get<T: Decodable>(_ type: T.Type, for key: Keys) -> T? {
        get(T.self, for: key.rawValue)
    }

    func get<T: Decodable>(_ type: T.Type, for key: String) -> T? {
        guard let data = try? getData(key) else {
            return nil
        }

        return try? decoder.decode(T.self, from: data)
    }
}
