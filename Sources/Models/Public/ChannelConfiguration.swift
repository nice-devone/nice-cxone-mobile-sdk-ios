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

/// The various options for how a channel is configured.
public struct ChannelConfiguration {
    
    /// Whether the channel supports multiple threads for the same user.
    public let hasMultipleThreadsPerEndUser: Bool

    /// Whether the channel supports proactive chat features.
    public let isProactiveChatEnabled: Bool

    /// Whether OAuth authorization is enabled for the channel.
    public let isAuthorizationEnabled: Bool
    
    /// Case custom fields definitions.
    public let contactCustomFieldDefinitions: [CustomFieldType]
    
    /// Customer custom fields definitions.
    public let customerCustomFieldDefinitions: [CustomFieldType]
}
