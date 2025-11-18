//
// Copyright (c) 2021-2025. NICE Ltd. All rights reserved.
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
// periphery:ignore:all - false positive; used in several DTO objects

import Combine
import Foundation

protocol ReceivedEvent {
    
    static var eventType: EventType? { get }

    var eventId: UUID { get }
    var eventType: EventType? { get }
    var postbackEventType: EventType? { get }
    var postbackErrorCode: EventErrorCode? { get }
}

extension ReceivedEvent {
    
    var realEventType: EventType? {
        eventType ?? postbackEventType
    }
    
    var postbackErrorCode: EventErrorCode? { nil }
}

extension Publisher where Output == ReceivedEvent {
    
    func with(errorCode: EventErrorCode) -> any Publisher<Output, Failure> {
        filter { event in
            event.postbackErrorCode == errorCode
        }
    }
    
    func with(eventType: EventType) -> any Publisher<Output, Failure> {
        filter { event in
            event.realEventType == eventType
        }
    }

    func asType<Type: ReceivedEvent>(_ type: Type.Type) -> any Publisher<Type, Failure> {
        compactMap { event in
            event as? Type
        }
    }

    func with<Type: ReceivedEvent>(type: EventType, as dataType: Type.Type) -> any Publisher<Type, Failure> {
        with(eventType: type).asType(dataType)
    }

    func with<Type: ReceivedEvent>(type: Type.Type) -> any Publisher<Type, Failure> {
        if let eventType = type.eventType {
            return with(type: eventType, as: type)
        } else {
            return asType(type)
        }
    }
    
    func with<Type: ReceivedEvent>(errorCode: EventErrorCode, as dataType: Type.Type) -> any Publisher<Type, Failure> {
        with(errorCode: errorCode).asType(dataType)
    }
}

extension Data {
    
    func toReceivedEvent() -> ReceivedEvent? {
        let decoder = JSONDecoder()

        if let error = try? decoder.decode(ServerError.self, from: self), !error.message.isEmpty {
            return error
        } else if let error = try? decoder.decode(OperationError.self, from: self) {
            return error
        } else if let generic = try? decoder.decode(GenericEventDTO.self, from: self) {
            do {
                switch generic.realEventType {
                case .none:
                    LogManager.error("event type not specified: \(self.utf8string ?? String(describing: generic))")
                    
                    return generic
                case .eventInS3:                      return try decoder.decode(EventInS3DTO.self, from: self)
                case .senderTypingStarted:            return try decoder.decode(AgentTypingEventDTO.self, from: self)
                case .senderTypingEnded:              return try decoder.decode(AgentTypingEventDTO.self, from: self)
                case .messageCreated:                 return try decoder.decode(MessageCreatedEventDTO.self, from: self)
                case .messageSeenChanged:             return try decoder.decode(MessageSeenChangedDTO.self, from: self)
                case .threadRecovered:                return try decoder.decode(ThreadRecoveredEventDTO.self, from: self)
                case .messageReadChanged:             return try decoder.decode(MessageReadByAgentEventDTO.self, from: self)
                case .contactInboxAssigneeChanged:    return try decoder.decode(ContactInboxAssigneeChangedEventDTO.self, from: self)
                case .threadListFetched:              return generic
                case .customerAuthorized:             return try decoder.decode(CustomerAuthorizedEventDTO.self, from: self)
                case .customerReconnected:            return generic
                case .moreMessagesLoaded:             return try decoder.decode(MoreMessagesLoadedEventDTO.self, from: self)
                case .threadArchived:                 return generic
                case .tokenRefreshed:                 return try decoder.decode(TokenRefreshedEventDTO.self, from: self)
                case .threadMetadataLoaded:           return try decoder.decode(ThreadMetadataLoadedEventDTO.self, from: self)
                case .fireProactiveAction:            return try decoder.decode(ProactiveActionEventDTO.self, from: self)
                case .caseStatusChanged:              return try decoder.decode(CaseStatusChangedEventDTO.self, from: self)
                case .setPositionInQueue:             return try decoder.decode(SetPositionInQueueEventDTO.self, from: self)
                case .liveChatRecovered:              return try decoder.decode(LiveChatRecoveredDTO.self, from: self)
                case let .some(type):
                    LogManager.warning("unknown event type: \(type)")
                    
                    return generic
                }
            } catch {
                LogManager.error("Error decoding event: \(error)")
                return nil
            }
        } else {
            return nil
        }
    }
}
