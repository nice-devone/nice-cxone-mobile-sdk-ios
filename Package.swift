// swift-tools-version:5.3

import PackageDescription
import Foundation

let package = Package(
    name: "CXOneChatSDK",
	platforms: [
		.iOS(.v13)
	],
    products: [
        .library(
            name: "CXOneChatSDK",
            targets: ["CXOneChatSDK"]),
    ],
    dependencies: [
		.package(url: "https://github.com/MessageKit/MessageKit", from: "3.3.0"),
        .package(url: "https://github.com/evgenyneu/keychain-swift", from: "20.0.0"),
        .package(url: "https://github.com/aws-amplify/aws-sdk-ios-spm", from: "2.27.6")
    ],
    targets: [
        .target(
            name: "CXOneChatSDK",
            dependencies: ["MessageKit",
                           .product(name: "AWSPinpoint", package: "aws-sdk-ios-spm"),
                           .product(name: "KeychainSwift", package: "keychain-swift")
            ],
			path: "Sources",
			resources: []),
        .testTarget(
            name: "CXOneChatSDKTests",
            dependencies: ["CXOneChatSDK", "MessageKit"],
			path: "Tests",
            resources: [
                .copy("CXOneChatSDKTests/Resources/CaseInboxAssigneeChanged.json"),
                .copy("CXOneChatSDKTests/Resources/consumerAuthorized.json"),
                .copy("CXOneChatSDKTests/Resources/authorize.json"),
                .copy("CXOneChatSDKTests/Resources/loadConfigResponse.json"),
                .copy("CXOneChatSDKTests/Resources/MessageCreated.json"),
                .copy("CXOneChatSDKTests/Resources/MessagePostSucess.json"),
                .copy("CXOneChatSDKTests/Resources/MessageReadEventByAgent.json"),
                .copy("CXOneChatSDKTests/Resources/recoverThreadEvenResponse.json"),
                .copy("CXOneChatSDKTests/Resources/ThreadListFetched.json"),
                .copy("CXOneChatSDKTests/Resources/threadMetadaLoaded.json"),
                .copy("CXOneChatSDKTests/Resources/ThreadRecovered.json"),
                .copy("CXOneChatSDKTests/Resources/ResponseCreateMessageEvent.json"),              
            ]),
    ]
)
