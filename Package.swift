// swift-tools-version:5.7
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

import PackageDescription
import Foundation

let package = Package(
    name: "CXoneChatSDK",
    platforms: [
        .iOS(.v15),
        .macOS(.v12)
    ],
    products: [
        .library(
            name: "CXoneChatSDK",
            targets: ["CXoneChatSDK"]
        ),
    ],
    dependencies: [
        .package(url: "https://github.com/evgenyneu/keychain-swift", from: "24.0.0"),
        .package(url: "https://github.com/Kolos65/Mockable", from: "0.0.11"),
        .package(url: "https://github.com/nice-devone/nice-cxone-mobile-guide-utility-ios.git", from: "3.2.0")
    ],
    targets: [
        .target(
            name: "CXoneChatSDK",
            dependencies: [
                .product(name: "KeychainSwift", package: "keychain-swift"),
                .product(name: "Mockable", package: "Mockable"),
                .product(name: "CXoneGuideUtility", package: "nice-cxone-mobile-guide-utility-ios")
            ],
            path: "Sources",
            resources: [
                .copy("../PrivacyInfo.xcprivacy")
            ],
            swiftSettings: [
                .define("MOCKING", .when(configuration: .debug))
            ],
            plugins: []
        )
    ]
)
