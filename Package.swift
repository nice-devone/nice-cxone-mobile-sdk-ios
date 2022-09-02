// swift-tools-version:5.5

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
        .package(url: "https://github.com/evgenyneu/keychain-swift", from: "20.0.0"),
    ],
    targets: [
        .target(
            name: "CXOneChatSDK",
            dependencies: [.product(name: "KeychainSwift", package: "keychain-swift")],
			path: "Sources",
			resources: []),
        .testTarget(
            name: "CXOneChatSDKTests",
            dependencies: ["CXOneChatSDK"],
			path: "Tests",
            resources: [
                .copy("CXOneChatSDKTests/Resources/CaseInboxAssigneeChanged.json"),
                .copy("CXOneChatSDKTests/Resources/ChannelConfiguration.json"),
                .copy("CXOneChatSDKTests/Resources/CustomerAuthorizedEvent.json"),
                .copy("CXOneChatSDKTests/Resources/MessageCreatedEvent.json"),
                .copy("CXOneChatSDKTests/Resources/MessagePostSuccess.json"),
                .copy("CXOneChatSDKTests/Resources/MessageReadEventByAgent.json"),
                .copy("CXOneChatSDKTests/Resources/ThreadListFetchedEvent.json"),
                .copy("CXOneChatSDKTests/Resources/ThreadMetadataLoadedEvent.json"),
                .copy("CXOneChatSDKTests/Resources/ThreadRecoveredEvent.json"),
                .copy("CXOneChatSDKTests/Resources/AttachmentUpload.json"),
                .copy("CXOneChatSDKTests/Resources/ConsumerAuthorizedWithAccessToken.json"),
                .copy("CXOneChatSDKTests/Resources/AccessToken.json"),
                .copy("CXOneChatSDKTests/Resources/CustomMessageCreatedEvent.json"),
                .copy("CXOneChatSDKTests/Resources/ServerError.json"),
                .copy("CXOneChatSDKTests/Resources/WelcomeMessage.json"),
                .copy("CXOneChatSDKTests/Resources/CustomPopup.json"),
                .copy("CXOneChatSDKTests/Resources/ProActiveActionCustomPopupWithEmtyVariables.json")
            ]),
    ]
)
