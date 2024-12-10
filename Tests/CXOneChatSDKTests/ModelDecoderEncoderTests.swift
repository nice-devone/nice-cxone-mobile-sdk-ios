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

// swiftlint:disable type_body_length file_length

import XCTest
@testable import CXoneChatSDK

class ModelDecoderEncoderTests: XCTestCase {
    
    // MARK: - Properties
    
    let dateProvider = DateProviderMock()
    
    private let decoder = JSONDecoder()
    private let encoder = JSONEncoder()
    
    // MARK: - ContactStatus
    
    func testContactStatusDecodeCorrectly() throws {
        var testCases: [(json: String, status: ContactStatus)] = ContactStatus.allCases.map { status in
            (getSimpleJson(key: "status", value: status.rawValue), status)
        }
        // Append manually some unknown status
        testCases.append((getSimpleJson(key: "status", value: "none"), .unknown))
        
        try testCases.forEach { element in
            guard let data = element.json.data(using: .utf8) else {
                throw DecodingError.valueNotFound(Data.self, DecodingError.Context(codingPath: [], debugDescription: element.json))
            }
            
            let dictionary = try decoder.decode([String: ContactStatus].self, from: data)
            
            XCTAssertEqual(dictionary["status"], element.status)
        }
    }
    
    func testContactStatusEncodeCorrectly() throws {
        try ContactStatus.allCases.forEach { element in
            let decoded = try decoder.decode(ContactStatus.self, from: try encoder.encode(element))
            
            XCTAssertEqual(decoded, element)
        }
    }
    
    // MARK: - EventType
    
    func testMessageEventTypeDecodeCorrectly() throws {
        var testCases: [(json: String, type: EventType)] = EventType.allCases.map { eventType in
            (getSimpleJson(key: "type", value: eventType.rawValue), eventType)
        }
        // Append manually some unknown event
        testCases.append((getSimpleJson(key: "type", value: "MessageDeleted"), .unknown))
        
        try testCases.forEach { element in
            guard let data = element.json.data(using: .utf8) else {
                throw DecodingError.valueNotFound(Data.self, DecodingError.Context(codingPath: [], debugDescription: element.json))
            }
            
            let dictionary = try decoder.decode([String: EventType].self, from: data)
            
            XCTAssertEqual(dictionary["type"], element.type)
        }
    }
    
    func testMessageEventTypeEncodeCorrectly() throws {
        try EventType.allCases.forEach { element in
            let decoded = try decoder.decode(EventType.self, from: try encoder.encode(element))
            
            XCTAssertEqual(decoded, element)
        }
    }
    
    // MARK: - AuthorizeCustomerEventDataDTO
    
    func testAuthorizeCustomerEventDataDTODecodeCorrectly() throws {
        let data = try loadBundleData(from: "AuthorizeCustomer", type: "json")
        let entity = try decoder.decode(AuthorizeCustomerEventDataDTO.self, from: data)
        
        XCTAssertEqual(entity.authorizationCode, "1234")
        XCTAssertEqual(entity.codeVerifier, "1234")
        XCTAssertTrue(entity.disableChannelInfo)
        XCTAssertEqual(entity.sdkPlatform, "ios")
        XCTAssertEqual(entity.sdkVersion, "1.0.0")
    }
    
    func testAuthorizeCustomerEventDataDTOEncodeCorrectly() throws {
        var entity = AuthorizeCustomerEventDataDTO(
            authorizationCode: "authCode",
            codeVerifier: "verifier",
            disableChannelInfo: false,
            sdkPlatform: "ios",
            sdkVersion: "2.0.0"
        )
        
        let data = try encoder.encode(entity)
        entity = try decoder.decode(AuthorizeCustomerEventDataDTO.self, from: data)
        
        XCTAssertEqual(entity.authorizationCode, "authCode")
        XCTAssertEqual(entity.codeVerifier, "verifier")
        XCTAssertFalse(entity.disableChannelInfo)
        XCTAssertEqual(entity.sdkPlatform, "ios")
        XCTAssertEqual(entity.sdkVersion, "2.0.0")
    }
    
    // MARK: - ReconnectCustomerEventDataDTO
    
    func testReconnectCustomerEventDataDTODecodeCorrectly() throws {
        let json = """
        {
            "accessToken": {
                "token": "token"
            }
        }
        """
        
        guard let data = json.data(using: .utf8) else {
            throw DecodingError.valueNotFound(Data.self, DecodingError.Context(codingPath: [], debugDescription: json))
        }
        
        let entity = try decoder.decode(ReconnectCustomerEventDataDTO.self, from: data)
        
        XCTAssertEqual(entity.token, "token")
    }
    
    func testReconnectCustomerEventDataDTOEncodeCorrectly() throws {
        var entity = ReconnectCustomerEventDataDTO(token: "token")
        
        let data = try encoder.encode(entity)
        entity = try decoder.decode(ReconnectCustomerEventDataDTO.self, from: data)
        
        XCTAssertEqual(entity.token, "token")
    }
    
    // MARK: - AccessTokenDTO
    
    func testAccessTokenDTODecodeCorrectly() throws {
        let json = """
        {
            "token": "token",
            "expiresIn": 12389126214
        }
        """
        
        guard let data = json.data(using: .utf8) else {
            throw DecodingError.valueNotFound(Data.self, DecodingError.Context(codingPath: [], debugDescription: json))
        }
        
        let entity = try decoder.decode(AccessTokenDTO.self, from: data)
        
        XCTAssertEqual(entity.token, "token")
    }
    
    // MARK: - SetContactCustomFieldsEventDataDTO
    
    func testSetContactCustomFieldsEventDataDTODecodeCorrectly() throws {
        let uuid = UUID()
        let json = """
        {
            "thread": {
                "idOnExternalPlatform": "\(uuid.uuidString)"
            },
            "customFields": [
                {
                    "ident": "key",
                    "value": "value",
                    "updatedAt": "2022-06-07T21:10:49+01:00"
                }
            ],
            "contact": {
                "id": "id"
            }
        }
        """
        
        guard let data = json.data(using: .utf8) else {
            throw DecodingError.valueNotFound(Data.self, DecodingError.Context(codingPath: [], debugDescription: json))
        }
        
        let entity = try decoder.decode(SetContactCustomFieldsEventDataDTO.self, from: data)
        
        XCTAssertEqual(entity.thread.idOnExternalPlatform, uuid)
        XCTAssertFalse(entity.customFields.isEmpty)
        XCTAssertEqual(entity.customFields.first?.value, "value")
        XCTAssertEqual(entity.contactId, "id")
    }
    
    // MARK: - ProactiveActionDataDTO
    
    func testProactiveActionDataDTOEncodeCorrectly() throws {
        var entity = ProactiveActionDataDTO(
            content: ProactiveActionDataMessageContentDTO(bodyText: "bodyText", headlineText: "headlineText", headlineSecondaryText: nil, image: "image"),
            customFields: [CustomFieldDTO(ident: "key", value: "value", updatedAt: dateProvider.now)],
            templateType: .fullImage,
            call2action: CallToActionDTO(isVisible: false, text: "text"),
            design: DesignDTO(
                background: DesignBackgroundDTO(color: "color", image: "image"),
                designBorder: DesignBorderDTO(size: 0, color: "color", radius: 0),
                designColor: DesignColorDTO(headlineColor: "color", headlineSecondaryColor: "color", bodyTextColor: "color"),
                designCall2Action: DesignCall2ActionDTO(textColor: "color", backgroundColor: "color")
            ),
            position: .bottomLeft,
            customJs: nil
        )
        
        let data = try encoder.encode(entity)
        entity = try decoder.decode(ProactiveActionDataDTO.self, from: data)
        
        XCTAssertEqual(entity.content.headlineText, "headlineText")
        XCTAssertEqual(entity.customFields.first?.value, "value")
        XCTAssertEqual(entity.templateType, .fullImage)
        XCTAssertEqual(entity.call2action?.isVisible, false)
        XCTAssertEqual(entity.design?.designColor.headlineColor, "color")
        XCTAssertEqual(entity.position, .bottomLeft)
        XCTAssertEqual(entity.customJs, nil)
    }
    
    // MARK: - SendMessageEventDataDTO
    
    func testSendMessageEventDataDTODecodeCorrectly() throws {
        var eventEntity = SendMessageEventDataDTO(
            thread: ThreadDTO(idOnExternalPlatform: UUID(), threadName: "name"),
            contentType: .text(MessagePayloadDTO(text: "text", postback: nil)),
            idOnExternalPlatform: UUID(),
            customer: CustomerCustomFieldsDataDTO(customFields: []),
            contact: ContactCustomFieldsDataDTO(customFields: []),
            attachments: [],
            deviceFingerprint: DeviceFingerprintDTO(),
            token: "token"
        )
        
        let data = try encoder.encode(eventEntity)
        eventEntity = try decoder.decode(SendMessageEventDataDTO.self, from: data)
        
        guard case .text(let entity) = eventEntity.contentType else {
            throw CXoneChatError.invalidData
        }
        
        XCTAssertEqual(entity.text, "text")
        
        XCTAssertEqual(eventEntity.thread.threadName, "name")
        XCTAssertEqual(eventEntity.token, "token")
    }
    
    // MARK: - SendOutboundMessageEventDataDTO
    
    func testSendOutboundMessageEventDataDTODecodeCorrectly() throws {
        var eventEntity = SendOutboundMessageEventDataDTO(
            thread: ThreadDTO(idOnExternalPlatform: UUID(), threadName: "name"),
            contentType: .text(MessagePayloadDTO(text: "text", postback: nil)),
            idOnExternalPlatform: UUID(),
            contactCustomFields: [],
            attachments: [],
            deviceFingerprint: DeviceFingerprintDTO(),
            token: "token"
        )
        
        let data = try encoder.encode(eventEntity)
        eventEntity = try decoder.decode(SendOutboundMessageEventDataDTO.self, from: data)
        
        guard case .text(let entity) = eventEntity.contentType else {
            throw CXoneChatError.invalidData
        }
        
        XCTAssertEqual(entity.text, "text")
        
        XCTAssertEqual(eventEntity.thread.threadName, "name")
        XCTAssertEqual(eventEntity.token, "token")
    }
    
    // MARK: - RefreshTokenPayloadDataDTO
    
    func testRefreshTokenPayloadDataDTODecodeCorrectly() throws {
        let json = """
        {
            "accessToken": {
                "token": "token"
            }
        }
        """
        
        guard let data = json.data(using: .utf8) else {
            throw DecodingError.valueNotFound(Data.self, DecodingError.Context(codingPath: [], debugDescription: json))
        }
        
        let entity = try decoder.decode(RefreshTokenPayloadDataDTO.self, from: data)
        
        XCTAssertEqual(entity.token, "token")
    }
    
    // MARK: - ExecuteTriggerEventPayloadDTO
    
    func testExecuteTriggerEventPayloadDTODecodeCorrectly() throws {
        let customerIdentity = UUID().uuidString
        let eventId = LowerCaseUUID()
        let visitorId = LowerCaseUUID()
        let triggerId = LowerCaseUUID()
        
        var entity = ExecuteTriggerEventPayloadDTO(
            eventType: .executeTrigger,
            brand: BrandDTO(id: 0),
            channel: ChannelIdentifierDTO(id: "channelId"),
            customerIdentity: CustomerIdentityDTO(idOnExternalPlatform: customerIdentity),
            eventId: eventId,
            visitorId: visitorId,
            triggerId: triggerId
        )
        
        let data = try encoder.encode(entity)
        entity = try decoder.decode(ExecuteTriggerEventPayloadDTO.self, from: data)
        
        XCTAssertEqual(entity.eventType, .executeTrigger)
        XCTAssertEqual(entity.brand.id, 0)
        XCTAssertEqual(entity.channel.id, "channelId")
        XCTAssertEqual(entity.customerIdentity.idOnExternalPlatform, customerIdentity)
        XCTAssertEqual(entity.eventId.uuid, eventId.uuid)
        XCTAssertEqual(entity.visitorId.uuid, visitorId.uuid)
        XCTAssertEqual(entity.triggerId.uuid, triggerId.uuid)
    }
    
    // MARK: - EventDataType
    
    func testEventDataTypeEncodeNoThrow() throws {
        let testCases: [EventDataType] = [
            .archiveThreadData(ThreadEventDataDTO(thread: ThreadDTO(idOnExternalPlatform: UUID(), threadName: "name"))),
            .loadThreadData(ThreadEventDataDTO(thread: ThreadDTO(idOnExternalPlatform: UUID(), threadName: "name"))),
            .sendMessageData(
                SendMessageEventDataDTO(
                    thread: ThreadDTO(idOnExternalPlatform: UUID(), threadName: "name"),
                    contentType: .text(MessagePayloadDTO(text: "text", postback: nil)),
                    idOnExternalPlatform: UUID(),
                    customer: CustomerCustomFieldsDataDTO(customFields: []),
                    contact: ContactCustomFieldsDataDTO(customFields: []),
                    attachments: [],
                    deviceFingerprint: DeviceFingerprintDTO(),
                    token: "token"
                )
            ),
            .sendOutboundMessageData(
                SendOutboundMessageEventDataDTO(
                    thread: ThreadDTO(idOnExternalPlatform: UUID(), threadName: "name"),
                    contentType: .text(MessagePayloadDTO(text: "text", postback: nil)),
                    idOnExternalPlatform: UUID(),
                    contactCustomFields: [],
                    attachments: [],
                    deviceFingerprint: DeviceFingerprintDTO(),
                    token: "token"
                )
            ),
            .loadMoreMessageData(
                LoadMoreMessagesEventDataDTO(
                    scrollToken: "scrollToken",
                    thread: ThreadDTO(idOnExternalPlatform: UUID(), threadName: "name"),
                    oldestMessageDatetime: dateProvider.now
                )
            ),
            .setContactCustomFieldsData(
                SetContactCustomFieldsEventDataDTO(
                    thread: ThreadDTO(idOnExternalPlatform: UUID(), threadName: "name"), customFields: [], contactId: "contactId"
                )
            ),
            .setCustomerCustomFieldData(ContactCustomFieldsDataDTO(customFields: [])),
            .customerTypingData(CustomerTypingEventDataDTO(thread: ThreadDTO(idOnExternalPlatform: UUID(), threadName: "name"))),
            .authorizeCustomerData(AuthorizeCustomerEventDataDTO(authorizationCode: "authCode", codeVerifier: "codeVerifier")),
            .reconnectCustomerData(ReconnectCustomerEventDataDTO(token: "token")),
            .updateThreadData(ThreadEventDataDTO(thread: ThreadDTO(idOnExternalPlatform: UUID(), threadName: "name"))),
            .refreshTokenPayload(RefreshTokenPayloadDataDTO(token: "token"))
        ]
        
        try testCases.forEach { element in
            XCTAssertNoThrow(try encoder.encode(element))
        }
    }
    
    // MARK: - StoreVisitorEventDataType
    
    func testStoreVisitorEventDataTypeEncodeNoThrow() throws {
        let testCases: [EventDataType] = [
            .storeVisitorPayload(
                VisitorDTO(
                    customerIdentity: nil,
                    browserFingerprint: DeviceFingerprintDTO(),
                    journey: JourneyDTO(url: "url", utm: UTMDTO(source: "source", medium: "medium", campaign: "campaign", term: "term", content: "content")),
                    customVariables: nil
                )
            ),
            .visitorEvent(
                VisitorsEventsDTO(
                    visitorEvents: [
                        VisitorEventDTO(
                            id: LowerCaseUUID(),
                            type: .custom,
                            createdAtWithMilliseconds: dateProvider.now.iso8601withFractionalSeconds,
                            data: nil
                        )
                    ]
                )
            )
        ]
        
        try testCases.forEach { element in
            XCTAssertNoThrow(try encoder.encode(element))
        }
    }
    
    // MARK: - VisitorEventDataType
    
    func testVisitorEventDataTypeEncodeNoThrow() throws {
        let testCases: [VisitorEventDataType] = [.custom("custom")]
        
        try testCases.forEach { element in
            XCTAssertNoThrow(try encoder.encode(element))
        }
    }
    
    // MARK: - StoreVisitorEventsPayloadDTO
    
    func testStoreVisitorEventsPayloadDTOEncodeCorrectly() throws {
        let data = try loadBundleData(from: "StoreVisitorEventsPayloadDTO", type: "json")

        let visitorId = UUID(uuidString: "c80f620c-7825-4695-aadd-cdfeb0bb7376")!
        let eventId = UUID(uuidString: "5812e395-89d0-4680-a142-3f3d32b65bf0")!
        
        let entity = StoreVisitorEventsPayloadDTO(
            eventType: .storeVisitorEvents,
            brand: BrandDTO(id: 0),
            visitorId: LowerCaseUUID(uuid: visitorId),
            id: LowerCaseUUID(uuid: eventId),
            data: .storeVisitorPayload(VisitorDTO(customerIdentity: nil, browserFingerprint: DeviceFingerprintDTO(), journey: nil, customVariables: nil)),
            channel: ChannelIdentifierDTO(id: "channelId")
        )
        
        guard let expectation = String(data: data, encoding: .utf8),
              let encoded = String(data: try encoder.encode(entity), encoding: .utf8)
        else {
            throw XCTError("Could not get Strings from Data entities.")
        }
        
        XCTAssertTrue(expectation.contains("destination"))
        XCTAssertTrue(expectation.contains("5812e395-89d0-4680-a142-3f3d32b65bf0"))
        XCTAssertTrue(encoded.contains("destination"))
        XCTAssertTrue(encoded.contains("5812e395-89d0-4680-a142-3f3d32b65bf0"))
        
        XCTAssertTrue(expectation.contains("eventType"))
        XCTAssertTrue(expectation.contains("StoreVisitorEvents"))
        XCTAssertTrue(encoded.contains("eventType"))
        XCTAssertTrue(encoded.contains("StoreVisitorEvents"))
        
        XCTAssertTrue(expectation.contains("visitor"))
        XCTAssertTrue(expectation.contains("c80f620c-7825-4695-aadd-cdfeb0bb7376"))
        XCTAssertTrue(encoded.contains("visitor"))
        XCTAssertTrue(encoded.contains("c80f620c-7825-4695-aadd-cdfeb0bb7376"))
    }
    
    func testThreadRecoveredEventDecodeCorrectly() throws {
        let data = try loadBundleData(from: "ThreadRecoveredEvent", type: "json")

        let threadRecover = try decoder.decode(ThreadRecoveredEventDTO.self, from: data)
        
        XCTAssertEqual(threadRecover.postback.data.customerCustomFields.count, 1)
        XCTAssertEqual(threadRecover.postback.data.customerCustomFields.first?.ident, "customer.customFields.age")
        XCTAssertEqual(threadRecover.postback.data.customerCustomFields.first?.value, "24")
        
        XCTAssertEqual(threadRecover.postback.data.consumerContact.customFields.count, 2)
        XCTAssertEqual(threadRecover.postback.data.consumerContact.customFields.first?.ident, "contact.customFields.department")
        XCTAssertEqual(threadRecover.postback.data.consumerContact.customFields.first?.value, "Sales")
    }
    
    func testThreadRecoveredEventFallbackDecodeCorrectly() throws {
        let data = try loadBundleData(from: "ThreadRecoveredEvent_fallback", type: "json")

        let threadRecover = try decoder.decode(ThreadRecoveredEventDTO.self, from: data)
        
        XCTAssertEqual(threadRecover.postback.data.customerCustomFields.count, 1)
        XCTAssertEqual(threadRecover.postback.data.customerCustomFields.first?.ident, "customer.customFields.age")
        XCTAssertEqual(threadRecover.postback.data.customerCustomFields.first?.value, "24")
        
        XCTAssertEqual(threadRecover.postback.data.consumerContact.customFields.count, 2)
        XCTAssertEqual(threadRecover.postback.data.consumerContact.customFields.first?.ident, "contact.customFields.department")
        XCTAssertEqual(threadRecover.postback.data.consumerContact.customFields.first?.value, "Sales")
    }
    
    // MARK: - EventInS3
    
    func testEventInS3DecodeCorrectly() throws {
        let data = try loadBundleData(from: "EventInS3+ThreadRecovered", type: "json")
        let genericEvent = try decoder.decode(GenericEventDTO.self, from: data)
        
        XCTAssertEqual(genericEvent.eventType, .eventInS3)
        
        let event = try decoder.decode(EventInS3DTO.self, from: data)
        
        XCTAssertEqual(event.originEventType, .threadRecovered)
    }
}

// MARK: - Helpers

private extension ModelDecoderEncoderTests {

    func getSimpleJson(key: String, value: String) -> String {
        """
        {"\(key)": "\(value)"}
        """
    }
}
