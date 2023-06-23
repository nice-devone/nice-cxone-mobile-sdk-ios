// swift-tools-version:5.7

import PackageDescription
import Foundation


let package = Package(
    name: "CXoneChatSDK",
    platforms: [
        .iOS(.v13),
        .macOS(.v10_15)
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
            resources: [],
            plugins: []
        ),
        .testTarget(
            name: "CXoneChatSDKTests",
            dependencies: ["CXoneChatSDK"],
            path: "Tests",
            resources: [
                .copy("CXoneChatSDKTests/Examples")
            ]
        )
    ]
)
