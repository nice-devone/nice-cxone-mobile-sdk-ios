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

import XCTest
@testable import CXoneChatSDK

class ConnectionProviderTests: CXoneXCTestCase {

    func testGetEnvironmentChannelConfigurationWrongURLThrows() async {
        await XCTAssertAsyncThrowsError(
            try await CXoneChat.connection.getChannelConfiguration(environment: .NA1, brandId: .min, channelId: "")
        )
    }
    
    func testGetEnvironmentChannelConfigurationThrows() async {
        await XCTAssertAsyncThrowsError(
            try await CXoneChat.connection.getChannelConfiguration(environment: .NA1, brandId: 0, channelId: "")
        )
    }
    
    func testGetEnvironmentChannelConfigurationNoThrow() async throws {
        _ = try await CXoneChat.connection.getChannelConfiguration(environment: .NA1, brandId: brandId, channelId: channelId)
    }
    
    func testGetChannelConfigurationWrongURLThrows() async {
        await XCTAssertAsyncThrowsError(
            try await CXoneChat.connection.getChannelConfiguration(chatURL: chatURL, brandId: 0, channelId: "")
        )
    }
    
    func testGetChannelConfigurationThrows() async {
        await XCTAssertAsyncThrowsError(
            try await CXoneChat.connection.getChannelConfiguration(chatURL: chatURL, brandId: 0, channelId: "")
        )
    }
    
    func testGetChannelConfigurationNoThrow() async throws {
            _ = try await CXoneChat.connection.getChannelConfiguration(chatURL: chatURL, brandId: brandId, channelId: channelId)
    }
    
    func testPrepareDefaultEnvironmentWithWrongParametersThrows() async {
        await XCTAssertAsyncThrowsError(
            try await CXoneChat.connection.prepare(environment: .NA1, brandId: brandId, channelId: "")
        )
    }
    
    func testCorrectDefaultEnvironmentPreparationNoThrow() async throws {
            _ = try await CXoneChat.connection.prepare(environment: .NA1, brandId: brandId, channelId: channelId)
    }
    
    func testPrepareCustomEnvironmentWithWrongParametersThrows() async {
        await XCTAssertAsyncThrowsError(
            try await CXoneChat.connection.prepare(chatURL: "", socketURL: "", brandId: brandId, channelId: "")
        )
    }
    
    func testCorrectCustomEnvironmentPreparationNoThrow() async throws {
            _ = try await CXoneChat.connection.prepare(chatURL: chatURL, socketURL: socketURL, brandId: brandId, channelId: channelId)
    }
    
    func testConnect() async throws {
        try await setUpConnection()
        
        XCTAssertTrue(socketService.isConnected)
        
        guard let url = socketService.socketUrl, let queryItems = URLComponents(url: url, resolvingAgainstBaseURL: false)?.queryItems else {
            throw XCTError("Failed to get query parameters")
        }
        
        let brandId = queryItems.first { $0.name == "brandId" }?.value
        let channelId = queryItems.first { $0.name == "channelId" }?.value
        let visitorId = queryItems.first { $0.name == "visitorId" }?.value
        let sdkVersion = queryItems.first { $0.name == "sdkVersion" }?.value
        let sdkPlatform = queryItems.first { $0.name == "sdkPlatform" }?.value
        
        XCTAssertEqual(brandId, self.brandId.description)
        XCTAssertEqual(channelId, self.channelId)
        XCTAssertEqual(visitorId, connectionContext.visitorId?.uuidString)
        XCTAssertEqual(sdkVersion, CXoneChatSDK.CXoneChat.version)
        XCTAssertEqual(sdkVersion, CXoneChatSDKModule.version)
        XCTAssertEqual(sdkPlatform, "ios")
    }
    
    func testConnectWithoutPrepareThrows() async {
        await XCTAssertAsyncThrowsError(
            try await CXoneChat.connection.connect()
        )
    }
    
    func testDisconnect() async throws {
        try await setUpConnection()
        
        XCTAssertTrue(socketService.isConnected)
        
        CXoneChat.connection.disconnect()
        
        XCTAssertFalse(socketService.isConnected)
    }
    
    func testPingThrowsIllegalChatState() {
        XCTAssertThrowsError(try CXoneChat.connection.ping())
        XCTAssertTrue(socketService.pingNumber == 0)
    }
    
    func testPingWorksCorrectly() async throws {
        try await setUpConnection()
        
        XCTAssertNoThrow(try CXoneChat.connection.ping())
        XCTAssertTrue(socketService.pingNumber != 0)
    }
    
    
    func testExecuteTriggerThrowsNoConnected() {
        XCTAssertThrowsError(try CXoneChat.connection.executeTrigger(UUID()))
    }
    
    func testExecuteTriggerNoThrow() async throws {
        try await setUpConnection()
        
        XCTAssertNoThrow(try CXoneChat.connection.executeTrigger(UUID()))
    }
    
    func testChannelIsMultithread() async throws {
        try await setUpConnection(channelConfiguration: MockData.getChannelConfiguration(isMultithread: true))

        XCTAssertEqual(connectionContext.chatMode, .multithread)
    }

    func testChannelIsSinglethread() async throws {
        try await setUpConnection(channelConfiguration: MockData.getChannelConfiguration(isMultithread: false))

        XCTAssertEqual(connectionContext.chatMode, .singlethread)
    }
    
    func testChannelIsLiveChat() async throws {
        try await setUpConnection(channelConfiguration: MockData.getChannelConfiguration(isLiveChat: true))

        XCTAssertEqual(connectionContext.chatMode, .liveChat)
    }

    func testChannelIsOfflineLiveChat() async throws {
        try await setUpConnection(channelConfiguration: MockData.getChannelConfiguration(isOnline: false, isLiveChat: true))

        XCTAssertEqual(connectionContext.chatMode, .liveChat)
        XCTAssertEqual(connectionContext.chatState, .offline)
    }
    
    func testChannelFeatureListNonEmpty() throws {
        let data = try loadBundleData(from: "ChannelConfiguration", type: "json")
        let configuration = try decoder.decode(ChannelConfigurationDTO.self, from: data)
        
        XCTAssertFalse(configuration.settings.features.isEmpty)
        XCTAssertFalse(configuration.settings.isEnabled(feature: "liveChatLogoHidden"))
        XCTAssertTrue(configuration.settings.isEnabled(feature: "isCoBrowsingEnabled"))
        XCTAssertTrue(configuration.settings.isEnabled(feature: "UnknownFeature"))
    }
}
