// swift-tools-version:5.7
//
// Copyright (c) 2021-2024. NICE Ltd. All rights reserved.
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
        .iOS(.v14),
        .macOS(.v11)
    ],
    products: [
        .library(
            name: "CXoneChatSDK",
            targets: ["CXoneChatSDK"]
        ),
    ],
    dependencies: [
        .package(url: "https://github.com/evgenyneu/keychain-swift", from: "20.0.0")
    ],
    targets: [
        .target(
            name: "CXoneChatSDK",
            dependencies: [
                .product(name: "KeychainSwift", package: "keychain-swift")
            ],
            path: "Sources",
            resources: [
                .copy("../PrivacyInfo.xcprivacy")
            ],
            plugins: []
        ),
        .testTarget(
            name: "CXoneChatSDKTests",
            dependencies: ["CXoneChatSDK"],
            path: "Tests",
            resources: [
                .copy("CXOneChatSDKTests/Samples/sample_video.mov")
            ]
        )
    ]
)
