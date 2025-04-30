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

/// Settings on a channel.
struct ChannelSettingsDTO {
    
    // MARK: - Properties
    
    /// Whether the channel supports multiple threads for the same user.
    let hasMultipleThreadsPerEndUser: Bool

    /// Whether the channel supports proactive chat features.
    let isProactiveChatEnabled: Bool

    /// Allowed file upload details.
    let fileRestrictions: FileRestrictionsDTO
    
    /// Currently handled features.
    ///
    /// If the feature is no longer listed, it is by default **on**.
    let features: [String: Bool]
    
    // MARK: - Computed properties

    /// Indication if  ``ChatThreadListProvider/load(with:)`` for ``ChatMode/liveChat``
    /// triggers a ``CXoneChatError/recoveringThreadFailed`` error in case of non existing thread.
    ///
    /// - Enabled – the error means some kind of issue with the thread
    /// - Disabled – the error indicates non existing thread –> soft error.
    var isRecoverLiveChatDoesNotFailEnabled: Bool {
        isEnabled(feature: "isRecoverLivechatDoesNotFailEnabled")
    }
}

// MARK: - Decodable

extension ChannelSettingsDTO: Decodable {
    
    enum CodingKeys: CodingKey {
        case hasMultipleThreadsPerEndUser
        case isProactiveChatEnabled
        case fileRestrictions
        case features
    }
    
    init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        self.hasMultipleThreadsPerEndUser = try container.decode(Bool.self, forKey: .hasMultipleThreadsPerEndUser)
        self.isProactiveChatEnabled = try container.decode(Bool.self, forKey: .isProactiveChatEnabled)
        self.fileRestrictions = try container.decode(FileRestrictionsDTO.self, forKey: .fileRestrictions)
        self.features = try container.decode([String: Bool].self, forKey: .features)
    }
}

// MARK: - Methods

extension ChannelSettingsDTO {
    
    /// Checks if a feature is enabled.
    ///
    /// If the feature is not found in the `features` dictionary, then it is enabled by default.
    ///
    /// - Parameter key: The name of the feature to check.
    ///
    /// - Returns: True if the feature is enabled, or if the feature is not found in the
    ///     `features` dictionary, then returns true by default.
    func isEnabled(feature key: String) -> Bool {
        guard let feature = features[key] else {
            LogManager.info("Feature `\(key)` is not listed in the feature toggles -> enabled by default.")
            return true
        }
        
        return feature
    }
}
