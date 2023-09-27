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
    
    // MARK: - Methods

    func testGetEnvironmentChannelConfigurationWrongURL() async {
        do {
            _ = try await CXoneChat.connection.getChannelConfiguration(environment: .NA1, brandId: .min, channelId: "")
            XCTFail("Should throw an error.")
        } catch {
            return
        }
    }
    
    func testGetEnvironmentChannelConfigurationThrows() async {
        do {
            _ = try await self.CXoneChat.connection.getChannelConfiguration(environment: .NA1, brandId: 0, channelId: "")
            XCTFail("Should throw an error.")
        } catch {
            return
        }
    }
    
    func testGetEnvironmentChannelConfigurationNoThrow() async throws {
        _ = try await self.CXoneChat.connection.getChannelConfiguration(environment: .NA1, brandId: brandId, channelId: channelId)
    }
    
    func testGetChannelConfigurationWrongURL() async {
        do {
            _ = try await CXoneChat.connection.getChannelConfiguration(chatURL: chatURL, brandId: 0, channelId: "")
            XCTFail("Should throw an error.")
        } catch {
            return
        }
    }
    
    func testGetChannelConfigurationThrow() async {
        do {
            _ = try await self.CXoneChat.connection.getChannelConfiguration(chatURL: chatURL, brandId: 0, channelId: "")
            XCTFail("Should throw an error.")
        } catch {
            return
        }
    }
    
    func testGetChannelConfigurationNoThrow() async throws {
        _ = try await self.CXoneChat.connection.getChannelConfiguration(chatURL: chatURL, brandId: brandId, channelId: channelId)
    }
    
    func testEnvironmentConnectionThrows() async {
        do {
            try await CXoneChat.connection.prepare(environment: .NA1, brandId: brandId, channelId: "")
            XCTFail("Should throw an error.")
        } catch {
            return
        }
    }
    
    func testEnvironmentConnectionNoThrow() async throws {
        try await CXoneChat.connection.connect(environment: .NA1, brandId: brandId, channelId: channelId)
    }
    
    func testConnectionThrows() async {
        do {
            try await CXoneChat.connection.prepare(chatURL: "", socketURL: "", brandId: brandId, channelId: "")
            XCTFail("Should throw an error.")
        } catch {
            return
        }
    }
    
    func testConnectionNoThrow() async throws {
        try await CXoneChat.connection.connect(chatURL: chatURL, socketURL: socketURL, brandId: brandId, channelId: channelId)
    }
    
    func testDisconnect() async throws {
        try await CXoneChat.connection.connect(chatURL: chatURL, socketURL: socketURL, brandId: brandId, channelId: channelId)
        
        XCTAssertTrue(socketService.isConnected)
        
        CXoneChat.connection.disconnect()
        
        XCTAssertFalse(socketService.isConnected)
    }
    
    func testPing() {
        CXoneChat.connection.ping()
        
        XCTAssertTrue(socketService.pingNumber != 0)
    }
    
    func testExecuteTriggerThrowsNoConnected() {
        XCTAssertThrowsError(try CXoneChat.connection.executeTrigger(UUID()))
    }
    
    func testExecuteTriggerNoThrow() async throws {
        try await CXoneChat.connection.connect(chatURL: chatURL, socketURL: socketURL, brandId: brandId, channelId: channelId)
        
        XCTAssertNoThrow(try CXoneChat.connection.executeTrigger(UUID()))
    }
    
    func testChannelConfiguration() async throws {
        try await CXoneChat.connection.connect(chatURL: chatURL, socketURL: socketURL, brandId: brandId, channelId: channelId)
        
        XCTAssertNoThrow(try CXoneChat.connection.executeTrigger(UUID()))
    }
}
