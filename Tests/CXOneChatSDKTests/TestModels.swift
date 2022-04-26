//
//  File.swift
//  
//
//  Created by Customer Dynamics Development on 10/21/21.
//

import XCTest
@testable import CXOneChatSDK
import CoreLocation

@available(iOS 13.0, *)
class TestModels: XCTestCase {
	func testAudioItem() {
		let item = MockAudioItem(url: URL(string: "https://captive.apple.com")!)
		XCTAssertNotNil(item)
	}
	
	func testContactItem() {
		let item = MockContactItem(name: "",
								   initials: "")
		XCTAssertNotNil(item)
	}
	
	func testCoordinateItem() {
		let item = CoordinateItem(location: CLLocation(latitude: 0, longitude: 0))
		XCTAssertNotNil(item)
	}
	
	func testImageMediaItem() {
		let item = ImageMediaItem(image: UIImage())
		XCTAssertNotNil(item)
	}
	
	func testImageUploadSuccess() {
		let item = ImageUploadSuccess(fileUrl: "")
		XCTAssertNotNil(item)
	}
	
	func testMessage() {
		let item = Message(messageType: .text, plugin: [], text: "", user: Customer(senderId: "", displayName: ""), messageId: UUID(), date: Date(), threadId: UUID(), isRead: true)
		XCTAssertNotNil(item)
	}
	
	func testThreadObject() {
		let item = ThreadObject(id: "", idOnExternalPlatform: UUID(), messages: [], threadAgent: Customer(senderId: "", displayName: ""))
		XCTAssertNotNil(item)
	}
	
	func testUser() {
		let item = Customer(senderId: "", displayName: "")
		XCTAssertNotNil(item)
	}
    
    func testCharacterSetNotNil() {
        let dict = ["data": "test"]
        let data = dict.percentEncoded()
        let unwrapedData = try! XCTUnwrap(data)
        XCTAssertNotNil(unwrapedData)
    }
    
    func testDateInMiliSeconds() {
        let date = Date()
        let seconds = Int64((date.timeIntervalSince1970 * 1000.0).rounded())
        
        XCTAssertEqual(seconds, date.millisecondsSince1970)
    }
    
    func testDateISOFractionalGetter() {
        let date = Date()
        let second = date.iso8601withFractionalSeconds
        XCTAssertTrue(second.count >= 19)
        XCTAssertTrue(second.isEmpty == false)
    }
    
//    func testconfigModelWithLiveChatTrueAndmultipleThreadFalse() {
//        let data = loadStubFromBundle(withName: "loadConfigResponse", extension: "json")
//        let config = try! JSONDecoder().decode(ChannelConfiguration.self, from: data)
//        XCTAssertNotNil(config)
//        XCTAssertTrue(config.isLiveChat)
//        XCTAssertFalse(config.settings.hasMultipleThreadsPerEndUser)
//    }
    
//    func testConfigModelWithLiveChatFalseandMultipleTHreadFalse() {
//        let string = """
//        {
//          "name": "Test LiveChat",
//          "isLiveChat": false,
//          "settings": {
//            "hasMultipleThreadsPerEndUser": false,
//            "liveChatAllowAudioNotification": true
//            }
//          }
//        """
//        let data = string.data(using: .utf8)
//        XCTAssertNotNil(data)
//        let config = try! JSONDecoder().decode(ChannelConfiguration.self, from: data!)
//        XCTAssertNotNil(config)
//        XCTAssertFalse(config.isLiveChat)
//        XCTAssertFalse(config.settings.hasMultipleThreadsPerEndUser)
//    }
    
    func testConfigResponseWithNullLiveChatNotDecode() {
        let string = """
        {
          "name": "Test LiveChat",
          "isLiveChat": null,
          "settings": {
            "hasMultipleThreadsPerEndUser": false,
            "liveChatAllowAudioNotification": true
            }
          }
        """
        let data = string.data(using: .utf8)
        XCTAssertNotNil(data)
        let config = try? JSONDecoder().decode(ChannelConfiguration.self, from: data!)
        XCTAssertNil(config)
    }
    
    func testConfigResponseWithNullHasMultipleThreadNotDecode() {
        let string = """
        {
          "name": "Test LiveChat",
          "isLiveChat": true,
          "settings": {
            "hasMultipleThreadsPerEndUser": null
            "liveChatAllowAudioNotification": true
            }
          }
        """
        let data = string.data(using: .utf8)
        XCTAssertNotNil(data)
        let config = try? JSONDecoder().decode(ChannelConfiguration.self, from: data!)
        XCTAssertNil(config)
    }
}
