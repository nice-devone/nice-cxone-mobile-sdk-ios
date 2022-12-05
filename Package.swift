// swift-tools-version:5.6

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
            targets: ["CXoneChatSDK"]),
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
                .copy("CXoneChatSDKTests/Resources/CaseInboxAssigneeChanged.json"),
                .copy("CXoneChatSDKTests/Resources/ChannelConfiguration.json"),
                .copy("CXoneChatSDKTests/Resources/CustomerAuthorizedEvent.json"),
                .copy("CXoneChatSDKTests/Resources/MessageCreatedEvent.json"),
                .copy("CXoneChatSDKTests/Resources/MessagePostSuccess.json"),
                .copy("CXoneChatSDKTests/Resources/MessageReadEventByAgent.json"),
                .copy("CXoneChatSDKTests/Resources/ThreadListFetchedEvent.json"),
                .copy("CXoneChatSDKTests/Resources/ThreadMetadataLoadedEvent.json"),
                .copy("CXoneChatSDKTests/Resources/ThreadRecoveredEvent.json"),
                .copy("CXoneChatSDKTests/Resources/AttachmentUpload.json"),
                .copy("CXoneChatSDKTests/Resources/ConsumerAuthorizedWithAccessToken.json"),
                .copy("CXoneChatSDKTests/Resources/AccessToken.json"),
                .copy("CXoneChatSDKTests/Resources/CustomMessageCreatedEvent.json"),
                .copy("CXoneChatSDKTests/Resources/ServerError.json"),
                .copy("CXoneChatSDKTests/Resources/InternalServerError.json"),
                .copy("CXoneChatSDKTests/Resources/WelcomeMessage.json"),
                .copy("CXoneChatSDKTests/Resources/CustomPopup.json"),
                .copy("CXoneChatSDKTests/Resources/ProActiveActionCustomPopupWithEmtyVariables.json"),
                .copy("CXoneChatSDKTests/Resources/StoreVisitorEventsPayloadDTO.json")
            ]
        ),
    ]
)
