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

    let browser: String

    let browserVersion: String

    let country: String

    // swiftlint:disable:next identifier_name
    let ip: String

    let language: String

    let location: String

    /// The type of application the customer is using (native or web app).
    let applicationType: String

    /// The operating system the customer is currently using.
    let os: String
    // swiftlint:disable:previous identifier_name
    
    /// The operating system version that the customer is currently using.
    let osVersion: String

    /// The type of device that the customer is currently using.
    let deviceType: String

    /// The token of the device for push notifications.
    let deviceToken: String

    init(
        browser: String = "",
        browserVersion: String = "",
        country: String = "",
        ip: String = "", // swiftlint:disable:this identifier_name
        language: String = "",
        location: String = "",
        applicationType: String = "native",
        os: String = "iOS", // swiftlint:disable:this identifier_name
        osVersion: String = UIDevice.current.systemVersion,
        deviceType: String = "mobile",
        deviceToken: String = ""
    ) {
        self.browser = browser
        self.browserVersion = browserVersion
        self.country = country
        self.ip = ip
        self.language = language
        self.location = location
        self.applicationType = applicationType
        self.os = os
        self.osVersion = osVersion
        self.deviceType = deviceType
        self.deviceToken = deviceToken
    }
}
