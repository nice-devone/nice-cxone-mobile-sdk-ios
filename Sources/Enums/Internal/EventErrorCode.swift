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

/// The different types of error that can be received from the WebSocket.
enum EventErrorCode: String, Codable {
    
    case customerAuthorizationFailed = "CustomerAuthorizationFailed"
    
    /// Legacy error code for customer authorization failure.
    ///
    /// This error code will be replaced by `customerAuthorizationFailed` in the future.
    case consumerAuthorizationFailed = "ConsumerAuthorizationFailed"
    
    case customerReconnectFailed = "CustomerReconnectionFailed"
    
    /// Legacy error code for customer reconnection failure.
    ///
    /// This error code will be replaced by `customerReconnectFailed` in the future.
    case consumerReconnectFailed = "ConsumerReconnectionFailed"
    
    case tokenRefreshFailed = "TokenRefreshingFailed"
    
    case recoveringThreadFailed = "RecoveringThreadFailed"
    
    case recoveringLivechatFailed = "RecoveringLivechatFailed"
    
    case inconsistentData = "InconsistentData"
}
