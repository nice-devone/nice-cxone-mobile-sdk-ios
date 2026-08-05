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

/// The different types of error that can be received from the WebSocket.
enum EventErrorCode: String, Codable {
    
    case recoveringThreadFailed = "RecoveringThreadFailed"
    
    case recoveringLivechatFailed = "RecoveringLivechatFailed"
    
    case inconsistentData = "InconsistentData"
    
    case sendingTranscriptFailed = "SendingTranscriptFailed"

    /// Fallback for backend error codes the SDK does not recognize.
    ///
    /// Without this, an unrecognized code would make ``OperationError`` decoding throw,
    /// the event would be silently dropped, and any `waitFor` awaiting its `eventId`
    /// would hang until timeout instead of surfacing the error.
    case unknown = "Unknown"

    // MARK: - Init

    init(from decoder: any Decoder) throws {
        let rawValue = try decoder.singleValueContainer().decode(String.self)

        self = EventErrorCode(rawValue: rawValue) ?? .unknown
    }
}
