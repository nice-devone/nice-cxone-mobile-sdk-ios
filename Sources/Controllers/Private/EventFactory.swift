//
//  File.swift
//  
//
//  Created by kjoe on 2/21/22.
//

import Foundation


class EventFactory {
    static let shared = EventFactory()
    
    private init() {}
    
    func recoverLivechatThreadEvent(brandId: Int, channelId: String, customer: CustomerIdentity, eventType: EventType, threadId: UUID? = nil) -> Event {
        var threadData: EventData? = nil
        if let id = threadId {
            threadData = EventData.archiveThread(RecoverThreadData(thread: CustomFieldThreadCodable(id: "\(channelId)_\(id.uuidString)",
                                                                                                    idOnExternalPlatform: id.uuidString)))
        }
        return Event(
            brandId: brandId,
            channelId: channelId,
            customerIdentity: customer,
            eventType: eventType,
            data: threadData)
    }

    func sendMessageEvent(brandId: Int, channel: String, thread: UUID, message: String, user: CustomerIdentity, attachments: [Attachment] = [], accessToken: AccessTokenPayload? = nil) -> Event {
        Event(brandId: brandId,
              channelId: channel,
              customerIdentity: user,
              eventType: EventType.sendMessage,
              data: .message(MessageEventData(thread: MessageThreadCodable(idOnExternalPlatform: thread,
                                                                                    threadName: ""),
                                                       messageContent: MessageContent( type: EventMessageType.text.rawValue,
                                                                                       payload: MessagePayload(text: message,
                                                                                                               elements: [])),
                                                       idOnExternalPlatform: UUID(),
                                                       customer:  CustomerFields(customFields: []),
                                                       contact: CustomerFields(customFields: []),
                                                       accessToken: accessToken,
                                                       attachments: attachments,
                                                       browserFingerPrint: BrowserFingerprint())))
    }

    func fetchThreadListEvent(brandId: Int, channel: String, customer: CustomerIdentity) -> Event {
        //let customerIdentity = CustomerIdentity(idOnExternalPlatform: customer)
        return Event(brandId: brandId,
                     channelId: channel,
                     customerIdentity: customer,
                     eventType: EventType.fetchThreadList)
    }
    
    func archiveThreadEvent(brandId: Int, channel: String, customer: CustomerIdentity, thread: CustomFieldThreadCodable ) -> Event {
        Event(brandId: brandId,
              channelId: channel,
              customerIdentity: customer,
              eventType: .archiveThread,
              data: .archiveThreadData(ArchiveThreadData(thread: thread)))
    }

    func loadMoreMessagesEvent(brandId: Int, channel: String, threadId: String, threadIdOnExternalPlatform: UUID, scrollToken: String, user: CustomerIdentity, oldestMessageDatetime: String) -> Event {
        Event(brandId: brandId,
              channelId: channel,
              customerIdentity: user,
              eventType: .loadMoreMessages,
              data: .loadMoreMessageData(
                LoadMoreMessageData(scrollToken: scrollToken,
                                    thread: CustomFieldThreadCodable(id: threadId,
                                                                     idOnExternalPlatform: threadIdOnExternalPlatform.uuidString),
                                    oldestMessageDatetime: oldestMessageDatetime,
                                    consumerContact: nil)))
    }

    func setConsumerContactCustomFieldsEvent(brandId: Int, channel: String, caseId: String, threadId: String, idOnExt: UUID, customer: CustomerIdentity, customFields: [CustomField]) -> Event {
        Event(brandId: brandId,
              channelId: channel,
              customerIdentity: customer,
              eventType: .setCustomerContactCustomFields,
              data: .setContactCustomFieldData(SetContactCustomFieldData(thread: CustomFieldThreadCodable(id: threadId,
                                                                                                          idOnExternalPlatform: idOnExt.uuidString),
                                                                         customFields: customFields,
                                                                         consumerContact: Contact(id: caseId))))
    }

    func setCustomerCustomFieldsEvent(brandId: Int, channelId: String, customerId: CustomerIdentity, customFields: [CustomField] ) -> Event {
        Event(brandId: brandId,
              channelId: channelId,
              customerIdentity:  customerId,
              eventType: .setCustomerCustomFields,
              data: .setCustomerCustomFieldData(SetCustomerCustomFieldData(customFields: customFields)))
        
    }

    func senderTypingStartedEvent(brandId: Int, channel: String, threadId: String, customer: CustomerIdentity) ->  Event {
        Event(brandId: brandId,
              channelId: channel,
              customerIdentity: customer,
              eventType: .senderTypingStarted,
              data: .clientTypingStartedData(ClientTypingStartedData(thread: ThreadCodable(id: threadId))))
    }

    func senderTypingEndedEvent(brandId: Int, channel: String, threadId: String, customer: CustomerIdentity) -> Event {
        Event(brandId: brandId,
              channelId: channel,
              customerIdentity: customer,
              eventType: .senderTypingEnded,
              data: .clientTypingStartedData(ClientTypingStartedData(thread: ThreadCodable(id: threadId))))
    }
    
    func authorizeConsumerEvent(brandId: Int, channel: String, authCode: String, user: CustomerIdentity, codeVerifier: String? = nil) -> Event {
        Event(brandId: brandId,
              channelId: channel,
              customerIdentity:  user,
              eventType: .authorizeCustomer,
              data: .connectUserAuth(ConnectUserAuth(authorization: ConnectUserAuthCode(authorizationCode: authCode,
                                    codeVerifier: codeVerifier
                                                                                       ))))
    }
    func reconnectConsumerEvent(brandId: Int, channel: String, user: CustomerIdentity, visitor: String, token: String?) -> ReconnectEvent {
        ReconnectEvent(brandId: brandId,
                       channelId: channel,
                       customerIdentity: user,
                       eventType: .reconnectConsumer,
                       visitor: visitor,
                       token: token)
    }
    
    func messageSeenByConsumer(brandId: Int, channel: String, thread: CustomFieldThreadCodable, customer: CustomerIdentity) -> Event {
        Event(brandId: brandId,
              channelId: channel,
              customerIdentity: customer,
              eventType: .messageSeenByCustomer,
              data: .archiveThread(RecoverThreadData(thread: thread)))
    }
    
    func loadThreadMetadataEvent(id: String, idOnExternalPlatform: UUID, brandId: Int, channel: String, customer: CustomerIdentity) -> Event {
        Event( brandId: brandId,
               channelId: channel,
               customerIdentity: customer,
               eventType: EventType.loadThreadMetadata,
               data: .archiveThread(RecoverThreadData(thread: CustomFieldThreadCodable(id: id,
                                                                                       idOnExternalPlatform: idOnExternalPlatform.uuidString))))
    }
    
    func refreshTokenEvent(brandId: Int, channel: String,  customer: CustomerIdentity, token: String ) -> RefreshToken {
        RefreshToken(action: "chatWindowEvent",
                     eventId: UUID().uuidString,
                     payload: RefreshTokenPayload(eventType: "RefreshToken",
                                                  brand: Brand(id: brandId ),
                                                  channel: Channel(id: channel),
                                                  consumerIdentity: customer,
                                                  data: RefreshTokenPayloadData(accessToken: AccessTokenPayload(token: token))))
    }
}
