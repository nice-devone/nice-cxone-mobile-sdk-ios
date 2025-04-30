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

/// Represents all info about details of a proactive action.
public struct ProactiveActionDetails {
    
    // MARK: - Properties

    /// The unique id of the action.
    public let id: UUID

    /// The name of the action.
    public let name: String

    /// The type of proactive action.
    public let type: ActionType

    /// Proactive action data message content.
    public let content: ProactiveActionDataMessageContent?
    
    // MARK: - Init
    
    /// - Parameters:
    ///   - id: The unique id of the action.
    ///   - name: The name of the action.
    ///   - type: The type of proactive action.
    ///   - data: The data of the action.
    public init(id: UUID, name: String, type: ActionType, content: ProactiveActionDataMessageContent?) {
        self.id = id
        self.name = name
        self.type = type
        self.content = content
    }
}
