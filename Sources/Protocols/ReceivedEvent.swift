//
// Copyright (c) 2021-2026. NICE Ltd. All rights reserved.
//
// Licensed under the NICE License;
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//    https://github.com/nice-devone/nice-cxone-mobile-sdk-ios/blob/main/LICENSE
//
// TO THE EXTENT PERMITTED BY APPLICABLE LAW, THE CXONE MOBILE SDK IS PROVIDED ON
// AN "AS IS" BASIS. NICE HEREBY DISCLAIMS ALL WARRANTIES AND CONDITIONS, EXPRESS
// OR IMPLIED, INCLUDING (WITHOUT LIMITATION) WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE, NON-INFRINGEMENT, AND TITLE.
//
// periphery:ignore:all - false positive; used in several DTO objects

import Foundation

/// A server-originated message that can be received over the WebSocket connection.
///
/// Every concrete event type decoded from raw socket data conforms to this protocol,
/// including typed DTOs (e.g. ``MessageCreatedEventDTO``, ``ThreadRecoveredEventDTO``)
/// as well as error envelopes (``OperationError``, ``ServerError``) and the generic
/// fallback ``GenericEventDTO`` used for event types that do not have a dedicated DTO.
///
/// ## Event identity
///
/// Each event carries an ``eventId`` that the SDK uses to correlate outgoing requests
/// with their inbound responses (see ``EventBroadcast/waitFor(_:eventType:origin:checkTokenExpiration:socketService:eventsService:file:line:)``).
///
/// ## Event type resolution
///
/// The server uses two different JSON fields to communicate the kind of event:
/// - `eventType` — present on push events (server-initiated notifications)
/// - `postbackEventType` — present on postback events (direct responses to a client request)
///
/// Use ``realEventType`` to obtain whichever field is non-nil without caring which
/// transport the event arrived on.
///
/// ## Conforming types
///
/// Conforming types declare their expected ``eventType`` as a static property so that
/// ``EventBroadcast`` listeners and ``EventReceiver/addListener(_:)-swift.method`` can
/// filter the broadcast stream without decoding every event.
protocol ReceivedEvent: Sendable {

    /// The event type this conforming type represents, used for static stream filtering.
    ///
    /// Listeners registered via ``EventReceiver`` match incoming events against this
    /// value before attempting a cast to the concrete type.  A `nil` value means the
    /// type accepts events of any type and relies solely on the cast to ``eventId``
    /// check (e.g. ``GenericEventDTO``, ``OperationError``).
    ///
    /// - Note: This is intentionally named differently from the instance ``eventType``
    ///   property to make clear that it is a type-level descriptor, not a decoded
    ///   runtime value.
    static var associatedEventType: EventType? { get }

    /// A unique identifier assigned by the server to each event.
    ///
    /// Used to correlate a response event with the outgoing request that triggered it.
    var eventId: String { get }

    /// The event type carried in the top-level `eventType` JSON field.
    ///
    /// Present for push events (unsolicited server notifications).  `nil` for postback
    /// events, which use ``postbackEventType`` instead.
    var eventType: EventType? { get }

    /// The event type carried in the nested `postback.eventType` JSON field.
    ///
    /// Present for postback events (direct responses to a client request).  `nil` for
    /// push events, which use ``eventType`` instead.
    var postbackEventType: EventType? { get }
}

extension ReceivedEvent {

    /// The effective event type, regardless of which JSON field carries it.
    ///
    /// Returns ``eventType`` when non-nil (push event), otherwise falls back to
    /// ``postbackEventType`` (postback event).  Consumers should always use this
    /// property instead of reading either field directly.
    var realEventType: EventType? {
        eventType ?? postbackEventType
    }

}

extension Data {

    /// Decodes raw WebSocket data into the most specific ``ReceivedEvent`` available.
    ///
    /// The decoding strategy is:
    /// 1. Try ``ServerError`` — a transport-level error envelope with a non-empty message.
    /// 2. Try ``OperationError`` — a logical operation failure returned by the server.
    /// 3. Decode ``GenericEventDTO`` to read the `eventType`, then dispatch to the
    ///    concrete DTO registered for that type.  Falls back to returning the generic
    ///    DTO itself for types that share its shape (e.g. `.threadListFetched`,
    ///    `.threadArchived`) or are unknown.
    ///
    /// - Returns: A ``ReceivedEvent`` on success, or `nil` if the data cannot be decoded
    ///   into any known shape (decode errors are logged via `LogManager`).
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
                case .moreMessagesLoaded:             return try decoder.decode(MoreMessagesLoadedEventDTO.self, from: self)
                case .threadArchived:                 return generic
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
