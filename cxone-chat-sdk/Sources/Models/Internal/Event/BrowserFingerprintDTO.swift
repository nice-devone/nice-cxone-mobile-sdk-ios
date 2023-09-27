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
import UIKit

/// Represents fingerprint data about the customer.
struct DeviceFingerprintDTO: Codable {
    
    var browser = ""

    var browserVersion = ""

    var country = ""

    var ip = ""

    var language = ""

    var location = ""

    /// The type of application the customer is using (native or web app).
    var applicationType = "native"

    /// The operating system the customer is currently using.
    var os = "iOS"

    /// The operating system version that the customer is currently using.
    var osVersion: String = UIDevice.current.systemVersion

    /// The type of device that the customer is currently using.
    var deviceType = "mobile"

    /// The token of the device for push notifications.
    var deviceToken = ""
}
