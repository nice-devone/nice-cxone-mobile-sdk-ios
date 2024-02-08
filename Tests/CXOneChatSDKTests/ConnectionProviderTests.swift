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
    
    func testChannelConfiguration() async throws {
        try await setUpConnection()
        
        XCTAssertNoThrow(try CXoneChat.connection.executeTrigger(UUID()))
    }
}
