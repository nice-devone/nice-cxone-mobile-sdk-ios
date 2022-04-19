// swift-tools-version:5.3
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "CXOneChatSDK",
	platforms: [
		.iOS(.v13)
	],
    products: [
        // Products define the executables and libraries a package produces, and make them visible to other packages.
        .library(
            name: "CXOneChatSDK",
            targets: ["CXOneChatSDK"]),
    ],
    dependencies: [
		.package(url: "https://github.com/MessageKit/MessageKit", from: "3.3.0"),
        .package(url: "https://github.com/aws-amplify/amplify-ios", .upToNextMajor(from: "1.0.0"))
        // Dependencies declare other packages that this package depends on.
        // .package(url: /* package url */, from: "1.0.0"),
    ],
    targets: [
        // Targets are the basic building blocks of a package. A target can define a module or a test suite.
        // Targets can depend on other targets in this package, and on products in packages this package depends on.
        .target(
            name: "CXOneChatSDK",
            dependencies: ["MessageKit",
                           .product(name: "Amplify", package: "amplify-ios"),
                           .product(name: "AWSCognitoAuthPlugin", package: "amplify-ios"),
                           .product(name: "AWSPinpointAnalyticsPlugin", package: "amplify-ios")
            ],
			path: "Sources",
			resources: [
				.process("Resources/Assets.xcassets"),
                .copy("Resources/amplifyconfiguration.json"),
                .copy("Resources/awsconfiguration.json")
			]),
        .testTarget(
            name: "CXOneChatSDKTests",
            dependencies: ["CXOneChatSDK", "MessageKit"],
			path: "Tests",
            resources: [
                .process("CXOneChatSDKTests/Resources/Assets.xcassets"),
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
