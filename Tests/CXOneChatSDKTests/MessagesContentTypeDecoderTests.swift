import XCTest
@testable import CXoneChatSDK


class MessagesContentTypeDecoderTests: XCTestCase {
    
    // MARK:  - Properties
    
    private let decoder = JSONDecoder()
    
    
    // MARK: - ContentType Text
    
    func testContentTypeTextDecodeCorrectly() throws {
        let data = try loadStubFromBundle(withName: "PluginMessages/MessageTypeText", extension: "json")
        
        let message = MessageMapper.map(try decoder.decode(MessageDTO.self, from: data))
        
        switch message.contentType {
        case .text(let text):
            XCTAssertEqual("Hello world", text)
        default:
            XCTFail()
        }
    }
    
    
    // MARK: - Content Type Plugin: Deeplink
    
    func testContentTypePluginDeeplinkDecodeCorrectly() throws {
        let data = try loadStubFromBundle(withName: "PluginMessages/MessageTypePluginDeeplink", extension: "json")
        
        let message = MessageMapper.map(try decoder.decode(MessageDTO.self, from: data))
        
        guard case .plugin(let plugin) = message.contentType else {
            throw CXoneChatError.invalidData
        }
        guard case .subElements(let entities) = plugin.element, case .button(let deeplinkButton) = entities.first else {
            throw CXoneChatError.invalidData
        }
        
        XCTAssertEqual(deeplinkButton.url?.absoluteString, "fb://profile/33138223345")
        XCTAssertEqual(deeplinkButton.text, "See this page")
        XCTAssertEqual(deeplinkButton.id, "Nkm0hRAiE")
    }
    
    
    // MARK: - Content Type Plugin: Text And Buttons
    
    func testContentTypePluginTextAndButtonsDecodeCorrectly() throws {
        let data = try loadStubFromBundle(withName: "PluginMessages/MessageTypePluginTextAndButtons", extension: "json")
        
        let message = MessageMapper.map(try decoder.decode(MessageDTO.self, from: data))
        
        guard case .plugin(let plugin) = message.contentType else {
            throw CXoneChatError.invalidData
        }
        guard case .textAndButtons(let entity) = plugin.element else {
            throw CXoneChatError.invalidData
        }
        
        XCTAssertEqual(entity.elements.count, 4)
        
        var subElementTextCount = 0
        var subElementButtonCount = 0
        
        entity.elements.forEach { element in
            if case .text = element {
                subElementTextCount += 1
            } else if case .button = element {
                subElementButtonCount += 1
            }
        }
        
        XCTAssertEqual(subElementTextCount, 1)
        XCTAssertEqual(subElementButtonCount, 3)
    }
    
    
    // MARK: - Content Type Plugin: Quick Replies
    
    func testContentTypePluginQuickRepliesDecodeCorrectly() throws {
        let data = try loadStubFromBundle(withName: "PluginMessages/MessageTypePluginQuickReplies", extension: "json")
        
        let message = MessageMapper.map(try decoder.decode(MessageDTO.self, from: data))
        
        guard case .plugin(let plugin) = message.contentType else {
            throw CXoneChatError.invalidData
        }
        guard case .quickReplies(let entity) = plugin.element else {
            throw CXoneChatError.invalidData
        }
        
        XCTAssertEqual(entity.elements.count, 4)
        
        var subElementTextCount = 0
        var subElementButtonCount = 0
        
        entity.elements.forEach { element in
            if case .text = element {
                subElementTextCount += 1
            } else if case .button = element {
                subElementButtonCount += 1
            }
        }
        
        XCTAssertEqual(subElementTextCount, 1)
        XCTAssertEqual(subElementButtonCount, 3)
    }
    
    
    // MARK: - Content Type Plugin: Menu
    
    func testContentTypePluginMenuDecodeCorrectly() throws {
        let data = try loadStubFromBundle(withName: "PluginMessages/MessageTypePluginMenu", extension: "json")
        
        let message = MessageMapper.map(try decoder.decode(MessageDTO.self, from: data))
        
        guard case .plugin(let plugin) = message.contentType else {
            throw CXoneChatError.invalidData
        }
        guard case .menu(let entity) = plugin.element else {
            throw CXoneChatError.invalidData
        }
        
        XCTAssertEqual(entity.elements.count, 6)
        
        var subElementTextCount = 0
        var subElementButtonCount = 0
        
        entity.elements.forEach { element in
            if case .text = element {
                subElementTextCount += 1
            } else if case .button = element {
                subElementButtonCount += 1
            }
        }
        
        XCTAssertEqual(subElementTextCount, 1)
        XCTAssertEqual(subElementButtonCount, 3)
    }
    
    
    // MARK: - Content Type Plugin: Satisfaction Survey
    
    func testContentTypePluginSatisfactionSurveyDecodeCorrectly() throws {
        let data = try loadStubFromBundle(withName: "PluginMessages/MessageTypePluginSatisfactionSurvey", extension: "json")
        
        let message = MessageMapper.map(try decoder.decode(MessageDTO.self, from: data))
        
        guard case .plugin(let plugin) = message.contentType else {
            throw CXoneChatError.invalidData
        }
        guard case .satisfactionSurvey(let entity) = plugin.element else {
            throw CXoneChatError.invalidData
        }
        
        XCTAssertEqual(entity.elements.count, 2)
        
        var subElementTextCount = 0
        var subElementButtonCount = 0
        
        entity.elements.forEach { element in
            if case .text = element {
                subElementTextCount += 1
            } else if case .button(let button) = element {
                subElementButtonCount += 1
                
                XCTAssertTrue(button.displayInApp)
                
            }
        }
        
        XCTAssertEqual(subElementTextCount, 1)
        XCTAssertEqual(subElementButtonCount, 1)
    }
    
    
    // MARK: - Content Type Plugin: Custom
    
    func testContentTypePluginCustomDecodeCorrectly() throws {
        let data = try loadStubFromBundle(withName: "PluginMessages/MessageTypePluginCustom", extension: "json")
        
        let message = MessageMapper.map(try decoder.decode(MessageDTO.self, from: data))
        
        guard case .plugin(let plugin) = message.contentType else {
            throw CXoneChatError.invalidData
        }
        guard case .custom(let entity) = plugin.element else {
            throw CXoneChatError.invalidData
        }
        
        XCTAssertEqual(entity.text, "See this page")
        XCTAssertEqual(entity.variables["color"] as? String, "green")
        XCTAssertEqual((entity.variables["buttons"]as? [Any])?.count, 2)
        XCTAssertEqual(((entity.variables["buttons"] as? [Any])?.first as? [String: Any])?["name"] as? String, "Confirm")
    }
    
    
    // MARK: - Content Type Plugin: Gallery
    
    func testContentTypePluginGalleryDecodeCorrectly() throws {
        let data = try loadStubFromBundle(withName: "PluginMessages/MessageTypePluginGallery", extension: "json")
        
        let message = MessageMapper.map(try decoder.decode(MessageDTO.self, from: data))
        
        guard case .plugin(let plugin) = message.contentType else {
            throw CXoneChatError.invalidData
        }
        guard case .gallery(let entities) = plugin.element else {
            throw CXoneChatError.invalidData
        }
        
        XCTAssertEqual(entities.count, 2)
    }
}
