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

import Foundation

class AnalyticsService: AnalyticsProvider {

    // MARK: - Properties

    private let jsonEncoder = JSONEncoder()
    
    var lastPageViewed: PageViewEventDTO?
    
    let socketService: SocketService
    let dateProvider: DateProvider

    var connectionContext: ConnectionContext {
        get { socketService.connectionContext }
        set { socketService.connectionContext = newValue }
    }
    var visitId: UUID? {
        connectionContext.visitId
    }

    /// Visit valid interval is 30 minutes
    let visitValidInterval: TimeInterval = 30 * 60
    
    // MARK: - Protocol Properties
    
    public var visitorId: UUID? {
        get { connectionContext.visitorId }
        set { connectionContext.visitorId = newValue }
    }

    // MARK: - Init

    init(socketService: SocketService, dateProvider: DateProvider) {
        self.socketService = socketService
        self.dateProvider = dateProvider
    }

    // MARK: - Public Protocol Implementation

    // These public protocol implementations just forward to the actual
    // private implementation.  The two are distinct to maintain the existing
    // interface while allowing tests to specify an additional date parameter.

    /// Reports to CXone that a some page/screen in the app has been viewed by the visitor.
    /// - Parameters:
    ///   - title: The title or description of the page that was viewed.
    ///   - url: A URL uniquely identifying the page.
    /// - Throws: ``CXoneChatError/notConnected`` if an attempt was made to use a method without connecting first.
    ///     Make sure you call the `connect` method first.
    /// - Throws: ``EncodingError.invalidValue(_:_:)`` if the given value is invalid in the current context for this format.
    /// - Throws: ``CXoneChatError/channelConfigFailure``` if the URL cannot be parsed, most likely because
    ///     environment.chatURL is not a valid URL.
    /// - Throws: ``URLError.badServerResponse`` if the URL Loading system received bad data from the server.
    /// - Throws: `EncodingError.invalidValue` if a non-conforming floating-point value is encountered during encoding, and the encoding strategy is `.throw`.
    /// - Throws: ``NSError`` object that indicates why the request failed
    public func viewPage(title: String, url: String) async throws {
        LogManager.trace("Reporting page view started - \(title).")

        let date = dateProvider.now
        let sendVisit = checkVisit(date: date)

        if sendVisit {
            try await trigger(.visitorVisit, date: date)
        }

        do {
            if let lastPageViewed = lastPageViewed, url != lastPageViewed.url && title != lastPageViewed.title {
                try await viewPageEnded(title: lastPageViewed.title, url: lastPageViewed.url)
            }
        } catch {
            error.logError()
        }

        lastPageViewed = PageViewEventDTO(title: title, url: url, timestamp: date)
        
        try await trigger(.pageView, date: date, data: lastPageViewed)
    }

    /// CXone reporting that a visitor has left a certain page/screen in the application.
    /// - Parameters:
    ///   - title: The title or description of the page that was left.
    ///   - url: A URL uniquely identifying the page.
    /// - Throws: ``CXoneChatError/pageViewNotCalled`` if an attempt was made to use a method without first reporting the screen as viewed.
    /// - Throws: ``CXoneChatError/notConnected`` if an attempt was made to use a method without connecting first.
    ///     Make sure you call the `connect` method first.
    /// - Throws: ``EncodingError.invalidValue(_:_:)`` if the given value is invalid in the current context for this format.
    /// - Throws: ``CXoneChatError/channelConfigFailure`` if the URL cannot be parsed, most likely because
    ///     ``Environment/chatURL`` is not a valid URL.
    /// - Throws: ``URLError.badServerResponse`` if the URL Loading system received bad data from the server.
    /// - Throws: `EncodingError.invalidValue` if a non-conforming floating-point value is encountered during encoding, and the encoding strategy is `.throw`.
    /// - Throws: ``NSError`` object that indicates why the request failed
    func viewPageEnded(title: String, url: String) async throws {
        guard let lastPageViewed else {
            return
        }
        
        let timeSpentInSeconds = Int(Date().timeIntervalSince(lastPageViewed.timestamp))
        LogManager.trace("Reporting page view ended - \(title) Time spent: \(timeSpentInSeconds).")
        
        if lastPageViewed.title == title, lastPageViewed.url == url {
            try await trigger(
                .timeSpentOnPage,
                date: dateProvider.now,
                data: TimeSpentOnPageEventDTO(url: url, title: title, timeSpentOnPage: timeSpentInSeconds)
            )
            
            self.lastPageViewed = nil
        }
    }

    /// Reports to CXone that the chat window/view has been opened by the visitor.
    /// - Throws: ``CXoneChatError/notConnected`` if an attempt was made to use a method without connecting first.
    ///     Make sure you call the `connect` method first.
    /// - Throws: ``EncodingError.invalidValue(_:_:)`` if the given value is invalid in the current context for this format.
    /// - Throws: ``CXoneChatError/channelConfigFailure``` if the URL cannot be parsed, most likely because
    ///     environment.chatURL is not a valid URL.
    /// - Throws: ``URLError.badServerResponse`` if the URL Loading system received bad data from the server.
    /// - Throws: `EncodingError.invalidValue` if a non-conforming floating-point value is encountered during encoding, and the encoding strategy is `.throw`.
    /// - Throws: ``NSError`` object that indicates why the request failed
    public func chatWindowOpen() async throws {
        LogManager.trace("Reporting chat window open.")
        
        try await trigger(.chatWindowOpened, date: dateProvider.now)
    }

    /// Reports to CXone that a conversion has occurred.
    /// - Parameters:
    ///   - type: The type of conversion. Can be any value.
    ///   - value: The value associated with the conversion (for example, unit amount). Can be any number.
    /// - Throws: ``CXoneChatError/notConnected`` if an attempt was made to use a method without connecting first.
    ///     Make sure you call the `connect` method first.
    /// - Throws: ``EncodingError.invalidValue(_:_:)`` if the given value is invalid in the current context for this format.
    /// - Throws: ``CXoneChatError/channelConfigFailure``` if the URL cannot be parsed, most likely because
    ///     environment.chatURL is not a valid URL.
    /// - Throws: ``URLError.badServerResponse`` if the URL Loading system received bad data from the server.
    /// - Throws: `EncodingError.invalidValue` if a non-conforming floating-point value is encountered during encoding, and the encoding strategy is `.throw`.
    /// - Throws: ``NSError`` object that indicates why the request failed
    public func conversion(type: String, value: Double) async throws {
        LogManager.trace("Reporting conversion occurred.")

        let date = dateProvider.now

        try await trigger(
            .conversion,
            date: date,
            data: ConversionEventDTO(type: type, value: value, timeStamp: date)
        )
    }

    /// Reports to CXone that a proactive action was displayed to the visitor.
    /// - Parameter data: The proactive action that was displayed.
    /// - Throws: ``CXoneChatError/notConnected`` if an attempt was made to use a method without connecting first.
    ///     Make sure you call the `connect` method first.
    /// - Throws: ``EncodingError.invalidValue(_:_:)`` if the given value is invalid in the current context for this format.
    /// - Throws: ``CXoneChatError/channelConfigFailure``` if the URL cannot be parsed, most likely because
    ///     environment.chatURL is not a valid URL.
    /// - Throws: ``URLError.badServerResponse`` if the URL Loading system received bad data from the server.
    /// - Throws: `EncodingError.invalidValue` if a non-conforming floating-point value is encountered during encoding, and the encoding strategy is `.throw`.
    /// - Throws: ``NSError`` object that indicates why the request failed
    public func proactiveActionDisplay(data: ProactiveActionDetails) async throws {
        try await proactiveAction(.proactiveActionDisplayed, data: data, date: dateProvider.now)
    }

    /// Reports to CXone that a proactive action was successful or fails and lead to a conversion.
    /// - Parameter data: The proactive action that was successful or fails.
    /// - Throws: ``CXoneChatError/notConnected`` if an attempt was made to use a method without connecting first.
    ///     Make sure you call the `connect` method first.
    /// - Throws: ``EncodingError.invalidValue(_:_:)`` if the given value is invalid in the current context for this format.
    /// - Throws: ``CXoneChatError/channelConfigFailure``` if the URL cannot be parsed, most likely because
    ///     environment.chatURL is not a valid URL.
    /// - Throws: ``URLError.badServerResponse`` if the URL Loading system received bad data from the server.
    /// - Throws: `EncodingError.invalidValue` if a non-conforming floating-point value is encountered during encoding, and the encoding strategy is `.throw`.
    /// - Throws: ``NSError`` object that indicates why the request failed
    public func proactiveActionClick(data: ProactiveActionDetails) async throws {
        try await proactiveAction(.proactiveActionClicked, data: data, date: dateProvider.now)
    }
    
    /// Reports to CXone that a proactive action was successful or fails and lead to a conversion.
    /// - Parameter data: The proactive action that was successful or fails.
    /// - Throws: ``CXoneChatError/notConnected`` if an attempt was made to use a method without connecting first.
    ///     Make sure you call the `connect` method first.
    /// - Throws: ``EncodingError.invalidValue(_:_:)`` if the given value is invalid in the current context for this format.
    /// - Throws: ``CXoneChatError/channelConfigFailure``` if the URL cannot be parsed, most likely because
    ///     environment.chatURL is not a valid URL.
    /// - Throws: ``URLError.badServerResponse`` if the URL Loading system received bad data from the server.
    /// - Throws: `EncodingError.invalidValue` if a non-conforming floating-point value is encountered during encoding, and the encoding strategy is `.throw`.
    /// - Throws: ``NSError`` object that indicates why the request failed
    public func proactiveActionSuccess(_ isSuccess: Bool, data: ProactiveActionDetails) async throws {
        try await proactiveAction(
            isSuccess ? .proactiveActionSuccess : .proactiveActionFailed,
            data: data,
            date: dateProvider.now
        )
    }
    
    /// - Throws: ``CXoneChatError/notConnected`` if an attempt was made to use a method without connecting first.
    ///     Make sure you call the `connect` method first.
    /// - Throws: ``EncodingError.invalidValue(_:_:)`` if the given value is invalid in the current context for this format.
    public func customVisitorEvent(data: VisitorEventDataType) throws {
        LogManager.trace("Reporting custom visitor event occurred.")

        try socketService.checkForConnection()

        let data = try jsonEncoder.encode(
            StoreVisitorEventsDTO(
                action: .chatWindowEvent,
                eventId: UUID(),
                payload: getVisitorEventsPayload(eventType: .custom, data: data)
            )
        )

        socketService.send(message: data.utf8string)
    }
}

// MARK: - Private Implementation Utilities

private extension AnalyticsService {
    
    /// Check and insure that there is a current visit.  A visit is current
    /// if it exists and if the last pageView was generated less than 30 minutes
    /// ago.
    ///
    /// - parameter date: Date of pageView event to be validated.
    /// - returns: true iff a new visit was generated, indicating that a visitorEvent
    /// should be sent to the analytics service.
    func checkVisit(date: Date) -> Bool {
        if connectionContext.visitDetails?.expires.compare(date) != .orderedDescending {
            // if there is no visit, or the current visit has expired
            // create a new visit expiring in 30 minutes.
            connectionContext.visitDetails = CurrentVisitDetails(
                visitId: UUID(),
                expires: date.addingTimeInterval(visitValidInterval)
            )

            return true
        } else {
            // if the visit is current, then we just update the visit
            // expiration date, maintaining the existing visit id.
            connectionContext.visitDetails = CurrentVisitDetails(
                visitId: connectionContext.visitId ?? UUID(),
                expires: date.addingTimeInterval(visitValidInterval)
            )

            return false
        }
    }

    /// Generate a ProactiveAction based event.
    /// - Parameters:
    ///     - type: type of proactive action based event.  Only .proactiveActionDisplayed, .proactiveActionClicked,
    ///     .proactiveActionSuccess, or .proactiveActionFailed should be passed.
    /// - Throws: ``CXoneChatError/notConnected`` if an attempt was made to use a method without connecting first.
    ///     Make sure you call the `connect` method first.
    /// - Throws: ``EncodingError.invalidValue(_:_:)`` if the given value is invalid in the current context for this format.
    /// - Throws: ``CXoneChatError/channelConfigFailure``` if the URL cannot be parsed, most likely because
    ///     environment.chatURL is not a valid URL.
    /// - Throws: ``URLError.badServerResponse`` if the URL Loading system received bad data from the server.
    /// - Throws: `EncodingError.invalidValue` if a non-conforming floating-point value is encountered during encoding, and the encoding strategy is `.throw`.
    /// - Throws: ``NSError`` object that indicates why the request failed
    func proactiveAction(_ type: AnalyticsEventType, data: ProactiveActionDetails, date: Date) async throws {
        assert(
            [
                .proactiveActionDisplayed,
                .proactiveActionClicked,
                .proactiveActionSuccess,
                .proactiveActionFailed
            ].contains(type)
        )

        LogManager.trace("Reporting proactive action \(type) details=\(data)")

        try await trigger(type, date: date, data: ProactiveEventDTO(from: data))
    }

    /// trigger an analytics event by sending it to the analytics service.
    ///
    /// - Parameters:
    ///     - type: type of event to trigger
    ///     - date: event date to set
    ///     - data: extra data defined by ``type``
    ///     - fun: function name for logging purpose
    ///     - file: file name for logging purpose
    ///     - line: line number for logging purpose
    /// - Throws: ``CXoneChatError/notConnected`` if an attempt was made to use a method without connecting first.
    ///     Make sure you call the `connect` method first.
    /// - Throws: ``EncodingError.invalidValue(_:_:)`` if the given value is invalid in the current context for this format.
    /// - Throws: ``CXoneChatError/channelConfigFailure``` if the URL cannot be parsed, most likely because
    ///     environment.chatURL is not a valid URL.
    /// - Throws: ``CXoneChatError/notConnected`` if an attempt was made to use a method without connecting first.
    ///     Make sure you call the `connect` method first.
    /// - Throws: ``URLError.badServerResponse`` if the URL Loading system received bad data from the server.
    /// - Throws: `EncodingError.invalidValue` if a non-conforming floating-point value is encountered during encoding, and the encoding strategy is `.throw`.
    /// - Throws: ``NSError`` object that indicates why the request failed
    func trigger(
        _ type: AnalyticsEventType,
        date: Date,
        data: Encodable = [String: String](),
        fun: StaticString = #function,
        file: StaticString = #file,
        line: UInt = #line
    ) async throws {
        try socketService.checkForConnection()
        
        guard let visitorId = visitorId else {
            throw CXoneChatError.missingVisitorId
        }

        let data = try AnalyticsEventDTO(
            type: type,
            connection: connectionContext,
            createdAt: date,
            data: data
        )

        try await post(event: data, brandId: connectionContext.brandId, visitorId: visitorId, fun: fun, file: file, line: line)
    }

    /// Post an event to the web-analytics service with specified brand and visitor ids.
    ///
    /// - Parameters:
    ///     - event: event to send
    ///     - brandId: brand to target
    ///     - visitorId: visitorId to target
    ///     - fun: function name for logging purpose
    ///     - file: file name for logging purpose
    ///     - line: line number for logging purpose
    /// - Throws:
    ///     - ``CXoneChatError/channelConfigFailure``` if the URL cannot be parsed, most likely because
    ///     environment.chatURL is not a valid URL.
    ///     - ``URLError.badServerResponse`` if the URL Loading system received bad data from the server.
    ///     - `EncodingError.invalidValue` if a non-conforming floating-point value is encountered during encoding, and the encoding strategy is `.throw`.
    ///     - ``NSError`` object that indicates why the request failed
    func post(
        event: AnalyticsEventDTO,
        brandId: Int,
        visitorId: UUID,
        fun: StaticString = #function,
        file: StaticString = #file,
        line: UInt = #line
    ) async throws {
        guard let base = URL(string: connectionContext.environment.chatURL),
              let url = URL(
                string: "/web-analytics/1.0/tenants/\(brandId)/visitors/\(visitorId.uuidString)/events",
                relativeTo: base
              ) else {
            throw CXoneChatError.channelConfigFailure
        }

        var request = URLRequest(url: url, method: .post, contentType: "application/json")
        request.httpBody = try JSONEncoder().encode(event)

        try await connectionContext.session.data(for: request, fun: fun, file: file, line: line)
    }

}

// MARK: - Private Custom Visitor Event implementation details

private extension AnalyticsService {

    /// - Throws: ``CXoneChatError/customerVisitorAssociationFailure`` if the customer could not be associated with a visitor.
    func getVisitorEventsPayload(eventType: EventType, data: VisitorEventDataType?) throws -> StoreVisitorEventsPayloadDTO {
        guard let visitorId = visitorId else {
            throw CXoneChatError.customerVisitorAssociationFailure
        }
        
        return StoreVisitorEventsPayloadDTO(
            eventType: .storeVisitorEvents,
            brand: BrandDTO(id: connectionContext.brandId),
            visitorId: LowerCaseUUID(uuid: visitorId),
            id: LowerCaseUUID(uuid: connectionContext.destinationId),
            data: .visitorEvent(
                VisitorsEventsDTO(
                    visitorEvents: [
                        VisitorEventDTO(
                            id: LowerCaseUUID(uuid: UUID()),
                            type: eventType,
                            createdAtWithMilliseconds: dateProvider.now.iso8601withFractionalSeconds,
                            data: data
                        )
                    ]
                )
            ),
            channel: ChannelIdentifierDTO(id: connectionContext.channelId)
        )
    }
}
