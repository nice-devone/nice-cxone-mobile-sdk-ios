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
import UIKit

/// Represents fingerprint data about the customer.
struct DeviceFingerprintDTO {
    /// Country code per locale.
    let country: String?

    /// Current IP address if available.
    let ipAddress: String?

    /// Language code per locale.
    let language: String?

    /// Current location if available.
    let location: String?

    /// The type of application the customer is using (native or web app).
    let applicationType: String?

    /// The operating system the customer is currently using.
    let operatingSystem: String?

    /// The operating system version that the customer is currently using.
    let osVersion: String?

    /// The type of device that the customer is currently using.
    let deviceType: String?

    /// The token of the device for push notifications.
    let deviceToken: String?

    init(
        country: String? = Locale.current.countryCode,
        ipAddress: String? = nil,
        language: String? = Locale.current.languageCode,
        location: String? = nil,
        applicationType: String? = "native",
        operatingSystem: String? = UIDevice.current.systemName,
        osVersion: String? = UIDevice.current.systemVersion,
        deviceType: String? = "mobile",
        deviceToken: String? = nil
    ) {
        self.country = country
        self.ipAddress = ipAddress
        self.language = language
        self.location = location
        self.applicationType = applicationType
        self.operatingSystem = operatingSystem
        self.osVersion = osVersion
        self.deviceType = deviceType
        self.deviceToken = deviceToken
    }
}

private extension Locale {
    var countryCode: String? {
        if #available(iOS 16, *) {
            region?.identifier
        } else {
            regionCode
        }
    }
}

extension DeviceFingerprintDTO: Codable {
    enum CodingKeys: String, CodingKey {
        case country
        case ipAddress = "ip"
        case language
        case location
        case applicationType
        case operatingSystem = "os"
        case osVersion
        case deviceType
        case deviceToken
    }
}
