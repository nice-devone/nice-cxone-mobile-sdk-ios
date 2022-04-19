//
//  TestMessageModel.swift
//  
//
//  Created by kjoe on 1/6/22.
//

import XCTest
@testable import CXOneChatSDK
import CoreLocation
import MessageKit
@available(iOS 13.0, *)
class TestMessageModel: XCTestCase {
    
    var consumerIdentity: CustomerIdentity?
    
    var messageThreadCodable: MessageThreadCodable?
    var messageContentPayload: MessagePayload?
    var messageContent: MessageContent?
    var messagePostData: EventData?
    
    var payload: EventPayload?
    
    var sut: Message?
    let brand: Brand = Brand(id: 0)
    let channel: Channel = Channel(id: "")
    let attachmentSuccess: AttachmentSuccess = AttachmentSuccess(id: "2", friendlyName: "ads", url: "dasda", securedPermanentUrl: "dada", previewUrl: "dad")
    let mesageCase: Case = Case(threadId: "")
    var messagePostSuccessMessage: MessagePostSuccessMessage?
    var messagePostSuccessData: MessagePostSuccessData?
    
    override func setUpWithError() throws {
        consumerIdentity = CustomerIdentity(idOnExternalPlatform: UUID().uuidString, firstName: "John", lastName: "Cena")
        messageThreadCodable =  MessageThreadCodable(idOnExternalPlatform: UUID(), threadName: "")
        messageContentPayload =  MessagePayload(text: "Thread Started", elements: [])
        messageContent = MessageContent(type: EventMessageType.text.rawValue,
                                        payload: messageContentPayload!)
        
        
        messagePostData = EventData.message(
            MessageEventData(
                thread: messageThreadCodable!,
                messageContent: messageContent! ,
                idOnExternalPlatform: UUID(),
                customer: CustomerFields(customFields: []),
                contact: CustomerFields(customFields: []),
                attachments: [], browserFingerPrint: BrowserFingerprint()))
        
        payload = EventPayload(
            brandId: 0,
            channelId: "",
            customerIdentity: consumerIdentity!,
            eventType: EventType.sendMessage,
            data: messagePostData)
        
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
       sut = nil
    }
    
    
//    func testMessagInitWithParamMessagePost() {
//        let messagePost = getMessagePost()
//        XCTAssertNotNil(messagePost)
//        sut = Message(message: messagePost)
//        XCTAssertNotNil(sut)
//    }
    
    func testMessageInitWithParamMessagePostSuccess() {
        let attach: [AttachmentSuccess] = [attachmentSuccess]
        let messagePostSuccessMessage = getMessagePostSuccessMessage(attach)
        XCTAssertNotNil(messagePostSuccessMessage)
        let messagePostSuccessData = getMessagePostSuccessData(messagePostSuccessMessage)
        XCTAssertNotNil(messagePostSuccessData)
        let messagePostSuccess = getMessagePostSuccess(messagePostSuccessData)
        XCTAssertNotNil(messagePostSuccess)
        sut = Message(message: messagePostSuccess)
        XCTAssertNotNil(sut)
    }
    
    func testMessageWithParamAttachmentSuccessThreadIdMessagePostBack() {
        
        let messagePostBack: MessagePostback = getMessagePostBack()
        XCTAssertNotNil(messagePostBack)
        sut = Message(attachment: attachmentSuccess, threadId: UUID(), message: messagePostBack)
        XCTAssertNotNil(sut)
        
    }
    
    func testMessageWithParamAttachmentSuccesMessagePostSuccess() {
        let messagePostSuccessMessage = getMessagePostSuccessMessage([attachmentSuccess])
        let messagePostSuccessData = getMessagePostSuccessData(messagePostSuccessMessage)
        let messagePostSucces = getMessagePostSuccess(messagePostSuccessData)
        sut = Message(attachment: attachmentSuccess, threadId: UUID(), message: messagePostSucces)
        XCTAssertNotNil(sut)
    }
    
  
    
    func testMessageWithParamsThreadPostBackandMessagePostBack() {
        let author = getAuthor()
        XCTAssertNotNil(author)
        let threadPostBack = getThreadPostBack(author)
        XCTAssertNotNil(threadPostBack)
        let messagePostBack = getMessagePostBack()
        XCTAssertNotNil(messagePostBack)
        sut = Message(thread: threadPostBack, message: messagePostBack)
        XCTAssertNotNil(sut)
    }
    
    func testMessageInitWithStringParam() {
        let messageElements = getMessageElement()
        XCTAssertNotNil(messageElements)
        let elements = [messageElements]
        let messagePayloadElement = getMessagePayloadElement(elements)
        XCTAssertNotNil(messagePayloadElement)
        let user = getUser()
        sut = Message(messageType: MessageTypeForReal.text ,
                      plugin: [messagePayloadElement],
                      text: "",
                      user: user,
                      messageId: UUID(),
                      date: Date(),
                      threadId: UUID(),
                      isRead: true)
        XCTAssertNotNil(sut)
    }
    
    func testMessageWithInitNSStringAttributedText() {
        let elements = getMessageElement()
        let user = getUser()
        let messagePayload = getMessagePayloadElement([elements])
        XCTAssertNotNil(messagePayload)
        XCTAssertEqual(messagePayload.elements.count, 1)
        let atributed = NSAttributedString(string: "a attributed String")
        sut = Message(messageType: .text, plugin: [messagePayload], attributedText: atributed, user: user, messageId: UUID(), date: Date(), threadId: UUID(), isRead: true)
        XCTAssertNotNil(sut)
    }
    
    func testMessageInitWithUIImage() {
        let elements = getMessageElement()
        XCTAssertNotNil(elements)
        let messagepayload = getMessagePayloadElement([elements])
        XCTAssertNotNil(messagepayload)
        XCTAssertEqual(messagepayload.elements.count, 1)
        sut = Message(messageType: .plugin, plugin: [messagepayload], image: UIImage(), user: getUser(), messageId: UUID(), date: Date(), threadId: UUID(), isRead: true)
        XCTAssertNotNil(sut)
    }
    
    func testMessageInitWithImageURl() {
        let elements = getMessageElement()
        XCTAssertNotNil(elements)
        let messagepayload = getMessagePayloadElement([elements])
        XCTAssertNotNil(messagepayload)
        XCTAssertEqual(messagepayload.elements.count, 1)
        let url = try! XCTUnwrap(URL(string: "https://localhost/image.jpg"))
        sut = Message(messageType: .plugin, plugin: [messagepayload], imageURL: url, user: getUser(), messageId: UUID(), date: Date(), threadId: UUID(), isRead: true)
        XCTAssertNotNil(sut)
    }
    func testMessageInitWithImageThumnail() {
        let elements = getMessageElement()
        XCTAssertNotNil(elements)
        let messagepayload = getMessagePayloadElement([elements])
        XCTAssertNotNil(messagepayload)
        XCTAssertEqual(messagepayload.elements.count, 1)
        sut = Message(messageType: .plugin, plugin: [messagepayload], thumbnail: UIImage(), user: getUser(), messageId: UUID(), date: Date(), threadId: UUID(), isRead: true)
        XCTAssertNotNil(sut)
    }
    
    func testMessageInitWithLocationThreadPostBack() {
        let elements = getMessageElement()
        XCTAssertNotNil(elements)
        let messagepayload = getMessagePayloadElement([elements])
        XCTAssertNotNil(messagepayload)
        XCTAssertEqual(messagepayload.elements.count, 1)
        let location = CLLocation(latitude: CLLocationDegrees(21.12975), longitude: CLLocationDegrees(-75.211235))
        XCTAssertEqual(location.coordinate.latitude, 21.12975)
        XCTAssertEqual(location.coordinate.longitude, -75.211235)
        sut = Message(messageType: .plugin, plugin: [messagepayload], location: location, user: getUser(), messageId: UUID(), date: Date(), threadId: UUID(), isRead: false)
        XCTAssertNotNil(sut)        
    }
    func testMessageInitWithEmoji() {
        let elements = getMessageElement()
        XCTAssertNotNil(elements)
        let messagepayload = getMessagePayloadElement([elements])
        XCTAssertNotNil(messagepayload)
        XCTAssertEqual(messagepayload.elements.count, 1)
        sut = Message(messageType: .plugin, plugin: [messagepayload], emoji: "😃", user: getUser(), messageId: UUID(), date: Date(), threadId: UUID(), isRead: false)
        XCTAssertNotNil(sut)
    }
    func testMessageInitWithAudioURL() {
        let elements = getMessageElement()
        XCTAssertNotNil(elements)
        let messagepayload = getMessagePayloadElement([elements])
        XCTAssertNotNil(messagepayload)
        XCTAssertEqual(messagepayload.elements.count, 1)
        let url = try! XCTUnwrap(URL(string: "https://captive.apple.com"))
        sut = Message(messageType: .plugin, plugin: [messagepayload], audioURL: url, user: getUser(), messageId: UUID(), date: Date(), threadId: UUID(), isRead: false)
        XCTAssertNotNil(sut)
    }
    func testMessageInitWithContact() {
        let elements = getMessageElement()
        XCTAssertNotNil(elements)
        let messagepayload = getMessagePayloadElement([elements])
        XCTAssertNotNil(messagepayload)
        XCTAssertEqual(messagepayload.elements.count, 1)
        let mockContact = MockContactItem(name: "yoel", initials: "yj")
        XCTAssertEqual(mockContact.initials, "yj")
        XCTAssertEqual(mockContact.displayName, "yoel")
        sut = Message(messageType: .plugin, plugin: [messagepayload], contact: mockContact, user: getUser(), messageId: UUID(), date: Date(), threadId: UUID(), isRead: true)
        XCTAssertNotNil(sut)
    }
    func testMessageInitWithMessageLinkItem() {
        let elements = getMessageElement()
        XCTAssertNotNil(elements)
        let messagepayload = getMessagePayloadElement([elements])
        XCTAssertNotNil(messagepayload)
        XCTAssertEqual(messagepayload.elements.count, 1)
        let attText = NSAttributedString(string: "hola")
        let url = try! XCTUnwrap(URL(string: "https://localhost/audio1.mp3"))
        let linkItem = MessageLinkItem(text: "rear text", attributedText: attText, url: url, title: "title", teaser: "", thumbnailImage: UIImage())
        sut = Message(messageType: .plugin, plugin: [messagepayload], linkItem: linkItem, user: getUser(), messageId: UUID(), date: Date(), threadId: UUID(), isRead: true)
        XCTAssertNotNil(sut)
    }
    
    
    fileprivate func getMessagePost() -> EventPayload {
        return EventPayload(brandId: 0,
                           channelId: "",
                           customerIdentity: consumerIdentity!,
                           eventType: EventType.sendMessage,
                           data: messagePostData!)
    }
    
    fileprivate func getMessagePostSuccessMessage(_ attach: [AttachmentSuccess]) -> MessagePostSuccessMessage {
        return MessagePostSuccessMessage(id: "1",
                                         idOnExternalPlatform: UUID(),
                                         postId: "1",
                                         threadId: "123",
                                         messageContent: messageContent!,
                                         createdAt: "new",
                                         isMadeByUser: true,
                                         isRead: true,
                                         attachments: attach,
                                         readAt: nil,
                                         user: nil,
                                         authorEndUserIdentity: nil)
    }
    
    fileprivate func getMessagePostSuccessData(_ messagePostSuccessMessage: MessagePostSuccessMessage) -> MessagePostSuccessData {
        return MessagePostSuccessData(brand: brand,
                                      channel: channel,
                                      case: mesageCase,
                                      thread: messageThreadCodable!,
                                      message: messagePostSuccessMessage)
    }
    
    fileprivate func getAuthor() -> Author {
        return Author(id: "me",
                      name: "I",
                      nickname: "kjoe")
    }
    
    fileprivate func getThreadPostBack(_ author: Author) -> ThreadPostback {
        return ThreadPostback(id: "id",
                              channelId: "",
                              idOnExternalPlatform: UUID(),
                              threadName: "name",
                              isOwn: true,
                              createdAt: "",
                              updatedAt: "",
                              author: author)
    }
    
    fileprivate func getMessagePostBack() -> MessagePostback {
        return MessagePostback(messageId: UUID(),
                               idOnExternalPlatform: UUID(),
                               isOwn: true,
                               url: "url",
                               messageContent: messageContent!,
                               isRead: true,
                               endUser: nil,
                               messageAssignedUser: nil,
                               createdAt: "sadad",
                               attachments: [attachmentSuccess])
    }
    
    fileprivate func getMessagePostSuccess(_ messagePostSuccessData: MessagePostSuccessData) -> MessagePostSuccess {
        return MessagePostSuccess(eventId: "",
                                  eventObject: "",
                                  eventType: "",
                                  createdAt: "",
                                  data: messagePostSuccessData)
    }
    
    fileprivate func getMessageElement() -> MessageElement {
        return MessageElement(id: "",
                              type: "",
                              text: "",
                              postback: "",
                              url: "",
                              fileName: "",
                              mimeType: "")
    }
    
    fileprivate func getMessagePayloadElement(_ elements: [MessageElement]) -> MessagePayloadElement {
        return MessagePayloadElement(id: "",
                                     type: "",
                                     text: "",
                                     postback: "",
                                     url: "",
                                     elements: elements)
    }
    
    fileprivate func getUser() -> Customer {
        return Customer(senderId: UUID().uuidString.lowercased(), displayName: "kjoe")
    }

}
