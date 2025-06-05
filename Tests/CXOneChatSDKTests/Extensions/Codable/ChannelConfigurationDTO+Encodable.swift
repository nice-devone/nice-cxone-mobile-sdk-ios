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

extension ChannelConfigurationDTO: Swift.Encodable {
    
    public func encode(to encoder: any Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        
        try container.encode(settings, forKey: .settings)
        try container.encode(isAuthorizationEnabled, forKey: .isAuthorizationEnabled)
        try container.encode(liveChatAvailability.isChannelLiveChat, forKey: .isLiveChat)
    }
}

// MARK: - Helpers

extension ChannelSettingsDTO: Swift.Encodable {

    public func encode(to encoder: any Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        
        try container.encode(hasMultipleThreadsPerEndUser, forKey: .hasMultipleThreadsPerEndUser)
        try container.encode(isProactiveChatEnabled, forKey: .isProactiveChatEnabled)
        try container.encode(fileRestrictions, forKey: .fileRestrictions)
        try container.encode(features, forKey: .features)
    }
}

extension FileRestrictionsDTO: Swift.Encodable {
    
    public func encode(to encoder: any Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        
        try container.encode(allowedFileSize.description, forKey: .allowedFileSize)
        try container.encode(allowedFileTypes, forKey: .allowedFileTypes)
        try container.encode(isAttachmentsEnabled, forKey: .isAttachmentsEnabled)
    }
}

extension AllowedFileTypeDTO: Swift.Encodable {
    
    public func encode(to encoder: any Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        
        try container.encode(mimeType, forKey: .mimeType)
        try container.encode(details, forKey: .details)
    }
}
