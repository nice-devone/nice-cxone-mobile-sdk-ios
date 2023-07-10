// swiftlint:disable type_body_length file_length

import XCTest
@testable import CXoneChatSDK


class ModelDecoderEncoderTests: XCTestCase {
    
    // MARK: - Properties
    
    let dateProvider = DateProviderMock()
    
    
    // MARK: - ContactStatus
    
    func testContactStatusDecodeCorrectly() throws {
        let testCases: [(json: String, type: ContactStatus)] = [
            ("{\"status\": \"none\"}", .unknown),
            ("{\"status\": \"new\"}", .new),
            ("{\"status\": \"unknown\"}", .unknown)
        ]
        
        try testCases.forEach { element in
            guard let data = element.json.data(using: .utf8) else {
                throw DecodingError.valueNotFound(Data.self, DecodingError.Context(codingPath: [], debugDescription: element.json))
            }
            
            let dictionary = try JSONDecoder().decode([String: ContactStatus].self, from: data)
            
            XCTAssertEqual(dictionary["status"], element.type)
        }
    }
    
    
    // MARK: - EventType
    
    func testMessageEventTypeDecodeCorrectly() throws {
        let testCases: [(json: String, type: EventType)] = [
            ("{\"type\": \"EventTriggered\"}", .unknown("EventTriggered")),
            ("{\"type\": \"AuthorizeCustomer\"}", .authorizeCustomer),
            ("{\"type\": \"ConsumerAuthorized\"}", .customerAuthorized),
            ("{\"type\": \"ReconnectCustomer\"}", .reconnectCustomer),
            ("{\"type\": \"ConsumerReconnected\"}", .customerReconnected),
            ("{\"type\": \"RefreshToken\"}", .refreshToken),
            ("{\"type\": \"TokenRefreshed\"}", .tokenRefreshed),
            ("{\"type\": \"CaseCreated\"}", .caseCreated),
            ("{\"type\": \"SendMessage\"}", .sendMessage),
            ("{\"type\": \"MessageCreated\"}", .messageCreated),
            ("{\"type\": \"LoadMoreMessages\"}", .loadMoreMessages),
            ("{\"type\": \"MoreMessagesLoaded\"}", .moreMessagesLoaded),
            ("{\"type\": \"MessageSeenByCustomer\"}", .messageSeenByCustomer),
            ("{\"type\": \"MessageSeenByUser\"}", .messageSeenByAgent),
            ("{\"type\": \"MessageReadChanged\"}", .messageReadChanged),
            ("{\"type\": \"RecoverThread\"}", .recoverThread),
            ("{\"type\": \"ThreadRecovered\"}", .threadRecovered),
            ("{\"type\": \"FetchThreadList\"}", .fetchThreadList),
            ("{\"type\": \"ThreadListFetched\"}", .threadListFetched),
            ("{\"type\": \"ArchiveThread\"}", .archiveThread),
            ("{\"type\": \"ThreadArchived\"}", .threadArchived),
            ("{\"type\": \"LoadThreadMetadata\"}", .loadThreadMetadata),
            ("{\"type\": \"ThreadMetadataLoaded\"}", .threadMetadataLoaded),
            ("{\"type\": \"UpdateThread\"}", .updateThread),
            ("{\"type\": \"ThreadUpdated\"}", .threadUpdated),
            ("{\"type\": \"CaseInboxAssigneeChanged\"}", .contactInboxAssigneeChanged),
            ("{\"type\": \"SetContactCustomFields\"}", .setContactCustomFields),
            ("{\"type\": \"SetCustomerCustomFields\"}", .setCustomerCustomFields),
            ("{\"type\": \"SenderTypingStarted\"}", .senderTypingStarted),
            ("{\"type\": \"SenderTypingEnded\"}", .senderTypingEnded),
            ("{\"type\": \"ExecuteTrigger\"}", .executeTrigger),
            ("{\"type\": \"StoreVisitor\"}", .storeVisitor),
            ("{\"type\": \"StoreVisitorEvents\"}", .storeVisitorEvents),
            ("{\"type\": \"FireProactiveAction\"}", .fireProactiveAction),
            ("{\"type\": \"SendOutbound\"}", .sendOutbound)
        ]
        
        try testCases.forEach { element in
            guard let data = element.json.data(using: .utf8) else {
                throw DecodingError.valueNotFound(Data.self, DecodingError.Context(codingPath: [], debugDescription: element.json))
            }
            
            let dictionary = try JSONDecoder().decode([String: EventType].self, from: data)
            
            XCTAssertEqual(dictionary["type"], element.type)
        }
    }
    
    func testMessageEventTypeEncodeCorrectly() throws {
        let testCases: [EventType] = [
            .authorizeCustomer, .customerAuthorized, .reconnectCustomer, .customerReconnected, .refreshToken,
            .tokenRefreshed, .caseCreated, .sendMessage, .messageCreated, .loadMoreMessages, .moreMessagesLoaded,
            .messageSeenByCustomer, .messageSeenByAgent, .messageReadChanged, .recoverThread, .threadRecovered,
            .fetchThreadList, .threadListFetched, .archiveThread, .threadArchived, .loadThreadMetadata, .threadMetadataLoaded,
            .updateThread, .threadUpdated, .contactInboxAssigneeChanged, .setContactCustomFields,
            .setCustomerCustomFields, .senderTypingStarted, .senderTypingEnded, .executeTrigger,
            .storeVisitor, .storeVisitorEvents, .fireProactiveAction, .sendOutbound
        ]
        
        try testCases.forEach { element in
            let decoded = try JSONDecoder().decode(EventType.self, from: try JSONEncoder().encode(element))
            
            XCTAssertEqual(decoded, element)
        }
    }
    
    
    // MARK: - AuthorizeCustomerEventDataDTO
    
    func testAuthorizeCustomerEventDataDTODecodeCorrectly() throws {
        let json = """
        {
            "authorization": {
                "authorizationCode": "authCode",
                "codeVerifier": "verifier"
            }
        }
        """
        
        guard let data = json.data(using: .utf8) else {
            throw DecodingError.valueNotFound(Data.self, DecodingError.Context(codingPath: [], debugDescription: json))
        }
        
        let entity = try JSONDecoder().decode(AuthorizeCustomerEventDataDTO.self, from: data)
        
        XCTAssertEqual(entity.authorizationCode, "authCode")
        XCTAssertEqual(entity.codeVerifier, "verifier")
    }
    
    func testAuthorizeCustomerEventDataDTOEncodeCorrectly() throws {
        var entity = AuthorizeCustomerEventDataDTO(authorizationCode: "authCode", codeVerifier: "verifier")
        
        let data = try JSONEncoder().encode(entity)
        entity = try JSONDecoder().decode(AuthorizeCustomerEventDataDTO.self, from: data)
        
        XCTAssertEqual(entity.authorizationCode, "authCode")
        XCTAssertEqual(entity.codeVerifier, "verifier")
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
        
        let entity = try JSONDecoder().decode(ReconnectCustomerEventDataDTO.self, from: data)
        
        XCTAssertEqual(entity.token, "token")
    }
    
    func testReconnectCustomerEventDataDTOEncodeCorrectly() throws {
        var entity = ReconnectCustomerEventDataDTO(token: "token")
        
        let data = try JSONEncoder().encode(entity)
        entity = try JSONDecoder().decode(ReconnectCustomerEventDataDTO.self, from: data)
        
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
        
        let entity = try JSONDecoder().decode(AccessTokenDTO.self, from: data)
        
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
        
        let entity = try JSONDecoder().decode(SetContactCustomFieldsEventDataDTO.self, from: data)
        
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
        
        let data = try JSONEncoder().encode(entity)
        entity = try JSONDecoder().decode(ProactiveActionDataDTO.self, from: data)
        
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
        
        let data = try JSONEncoder().encode(eventEntity)
        eventEntity = try JSONDecoder().decode(SendMessageEventDataDTO.self, from: data)
        
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
        
        let data = try JSONEncoder().encode(eventEntity)
        eventEntity = try JSONDecoder().decode(SendOutboundMessageEventDataDTO.self, from: data)
        
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
        
        let entity = try JSONDecoder().decode(RefreshTokenPayloadDataDTO.self, from: data)
        
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
        
        let data = try JSONEncoder().encode(entity)
        entity = try JSONDecoder().decode(ExecuteTriggerEventPayloadDTO.self, from: data)
        
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
            XCTAssertNoThrow(try JSONEncoder().encode(element))
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
                            type: .pageView,
                            createdAtWithMilliseconds: dateProvider.now.iso8601withFractionalSeconds,
                            data: nil
                        )
                    ]
                )
            )
        ]
        
        try testCases.forEach { element in
            XCTAssertNoThrow(try JSONEncoder().encode(element))
        }
    }
    
    
    // MARK: - VisitorEventDataType
    
    func testVisitorEventDataTypeEncodeNoThrow() throws {
        let testCases: [VisitorEventDataType] = [
            .conversionData(ConversionData(type: "", value: 0.0, timeWithMilliseconds: dateProvider.now.iso8601withFractionalSeconds)),
            .custom("custom"),
            .pageViewData(PageViewData(url: "", title: "")),
            .proactiveActionData(ProactiveActionDetails(id: UUID(), name: "name", type: .welcomeMessage, content: nil))
        ]
        
        try testCases.forEach { element in
            XCTAssertNoThrow(try JSONEncoder().encode(element))
        }
    }
    
    
    // MARK: - StoreVisitorEventsPayloadDTO
    
    func testStoreVisitorEventsPayloadDTOEncodeCorrectly() throws {
        let data = try loadStubFromBundle(withName: "StoreVisitorEventsPayloadDTO", extension: "json")
        
        guard let visitorId = UUID(uuidString: "c80f620c-7825-4695-aadd-cdfeb0bb7376") else {
            throw CXoneChatError.missingParameter("visitorId")
        }
        guard let eventId = UUID(uuidString: "5812e395-89d0-4680-a142-3f3d32b65bf0") else {
            throw CXoneChatError.missingParameter("visitorId")
        }
        
        let entity = StoreVisitorEventsPayloadDTO(
            eventType: .storeVisitorEvents,
            brand: BrandDTO(id: 0),
            visitorId: LowerCaseUUID(uuid: visitorId),
            id: LowerCaseUUID(uuid: eventId),
            data: .storeVisitorPayload(VisitorDTO(customerIdentity: nil, browserFingerprint: DeviceFingerprintDTO(), journey: nil, customVariables: nil)),
            channel: ChannelIdentifierDTO(id: "channelId")
        )
        
        guard let expectation = String(data: data, encoding: .utf8),
              let encoded = String(data: try JSONEncoder().encode(entity), encoding: .utf8)
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
        let data = try loadStubFromBundle(withName: "ThreadRecoveredEvent", extension: "json")
        
        let threadRecover = try JSONDecoder().decode(ThreadRecoveredEventDTO.self, from: data)
        
        XCTAssertEqual(threadRecover.postback.data.customerContactFields.count, 1)
        XCTAssertEqual(threadRecover.postback.data.customerContactFields.first?.ident, "customer.customFields.age")
        XCTAssertEqual(threadRecover.postback.data.customerContactFields.first?.value, "24")
        
        XCTAssertEqual(threadRecover.postback.data.consumerContact.customFields.count, 2)
        XCTAssertEqual(threadRecover.postback.data.consumerContact.customFields.first?.ident, "contact.customFields.department")
        XCTAssertEqual(threadRecover.postback.data.consumerContact.customFields.first?.value, "Sales")
    }
    
    func testThreadRecoveredEventFallbackDecodeCorrectly() throws {
        let data = try loadStubFromBundle(withName: "ThreadRecoveredEvent_fallback", extension: "json")
        
        let threadRecover = try JSONDecoder().decode(ThreadRecoveredEventDTO.self, from: data)
        
        XCTAssertEqual(threadRecover.postback.data.customerContactFields.count, 1)
        XCTAssertEqual(threadRecover.postback.data.customerContactFields.first?.ident, "customer.customFields.age")
        XCTAssertEqual(threadRecover.postback.data.customerContactFields.first?.value, "24")
        
        XCTAssertEqual(threadRecover.postback.data.consumerContact.customFields.count, 2)
        XCTAssertEqual(threadRecover.postback.data.consumerContact.customFields.first?.ident, "contact.customFields.department")
        XCTAssertEqual(threadRecover.postback.data.consumerContact.customFields.first?.value, "Sales")
    }
}
