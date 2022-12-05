import XCTest
@testable import CXoneChatSDK


class ConnectionProviderTests: CXoneXCTestCase {
    
    // MARK: - Methods
    
    func testGetEnvironmentChannelConfigurationWrongURL() async {
        do {
            _ = try await self.CXoneChat.connection.getChannelConfiguration(environment: .NA1, brandId: .min, channelId: "\"")
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
    
    func testGetEnvironmentChannelConfigurationNoThrows() async throws {
        _ = try await self.CXoneChat.connection.getChannelConfiguration(environment: .NA1, brandId: brandId, channelId: channelId)
    }
    
    func testGetChannelConfigurationWrongURL() async {
        do {
            _ = try await self.CXoneChat.connection.getChannelConfiguration(chatURL: chatURL, brandId: 0, channelId: "\"")
            XCTFail("Should throw an error.")
        } catch {
            return
        }
    }
    
    func testGetChannelConfigurationThrows() async {
        do {
            _ = try await self.CXoneChat.connection.getChannelConfiguration(chatURL: chatURL, brandId: 0, channelId: "")
            XCTFail("Should throw an error.")
        } catch {
            return
        }
    }
    
    func testGetChannelConfigurationNoThrows() async throws {
        _ = try await self.CXoneChat.connection.getChannelConfiguration(chatURL: chatURL, brandId: brandId, channelId: channelId)
    }
    
    func testEnvironmentConnectionThrows() async {
        do {
            try await self.CXoneChat.connection.connect(environment: .NA1, brandId: brandId, channelId: "\"")
            XCTFail("Should throw an error.")
        } catch {
            return
        }
    }
    
    func testEnvironmentConnectionNoThrows() async throws {
        try await CXoneChat.connection.connect(environment: .NA1, brandId: brandId, channelId: channelId)
    }
    
    func testConnectionThrows() async {
        do {
            try await self.CXoneChat.connection.connect(chatURL: "", socketURL: "", brandId: 0, channelId: "")
            XCTFail("Should throw an error.")
        } catch {
            return
        }
    }
    
    func testConnectionNoThrows() async throws {
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
    
    func testExecuteTriggerNoThrows() async throws {
        try await CXoneChat.connection.connect(chatURL: chatURL, socketURL: socketURL, brandId: brandId, channelId: channelId)
        
        XCTAssertNoThrow(try CXoneChat.connection.executeTrigger(UUID()))
    }
    
    func testChannleConfiguration() async throws {
        try await CXoneChat.connection.connect(chatURL: chatURL, socketURL: socketURL, brandId: brandId, channelId: channelId)
        
        XCTAssertNoThrow(try CXoneChat.connection.executeTrigger(UUID()))
    }
}
