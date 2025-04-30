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

import Foundation

class AnalyticsService {

    // MARK: - Properties

    private let jsonEncoder = JSONEncoder()
    
    let socketService: SocketService
    /// Visit valid interval is 30 minutes
    let visitValidInterval: TimeInterval = 30 * 60
    
    var lastPageViewed: PageViewEventDTO?
    
    var connectionContext: ConnectionContext {
        socketService.connectionContext
    }

    // MARK: - Init

    init(socketService: SocketService) {
        self.socketService = socketService
    }
}
 
// MARK: - AnalyticsProvider Implementation

// These public protocol implementations just forward to the actual
// private implementation.  The two are distinct to maintain the existing
// interface while allowing tests to specify an additional date parameter.
extension AnalyticsService: AnalyticsProvider {
    
    public var visitorId: UUID? {
        get { connectionContext.visitorId }
        set { connectionContext.visitorId = newValue }
    }

    /// Reports to CXone that a some page/screen in the app has been viewed by the visitor.
    /// - Parameters:
    ///   - title: The title or description of the page that was viewed.
    ///   - url: A URL uniquely identifying the page.
    ///
    /// - Throws: ``CXoneChatError/illegalChatState``if the SDK is not in the required state to trigger the method.
    /// - Throws: ``EncodingError.invalidValue(_:_:)`` if the given value is invalid in the current context for this format.
    /// - Throws: ``CXoneChatError/missingVisitorId``
    /// if ``ConnectionProvider/prepare(environment:brandId:channelId:)`` or ``ConnectionProvider/prepare(chatURL:socketURL:brandId:channelId:)``
    /// method was not called before triggering analytics event.
    /// - Throws: ``CXoneChatError/channelConfigFailure`` if the URL cannot be parsed, most likely because
    ///     environment.chatURL is not a valid URL.
    /// - Throws: ``URLError.badServerResponse`` if the URL Loading system received bad data from the server.
    /// - Throws: `EncodingError.invalidValue` if a non-conforming floating-point value is encountered during encoding, and the encoding strategy is `.throw`.
    /// - Throws: ``NSError`` object that indicates why the request failed
    /// - Throws: An error if any value throws an error during encoding.
    public func viewPage(title: String, url: String) async throws {
        guard connectionContext.chatState.isAnalyticsAvailable else {
            throw CXoneChatError.illegalChatState
        }
        
        LogManager.trace("Reporting page view started - \(title).")

        let date = Date.provide()
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
    ///
    /// - Throws: ``CXoneChatError/illegalChatState``if the SDK is not in the required state to trigger the method.
    /// - Throws: ``CXoneChatError/missingVisitorId``
    /// if ``ConnectionProvider/prepare(environment:brandId:channelId:)`` or ``ConnectionProvider/prepare(chatURL:socketURL:brandId:channelId:)``
    /// method was not called before triggering analytics event.
    /// - Throws: ``EncodingError.invalidValue(_:_:)`` if the given value is invalid in the current context for this format.
    /// - Throws: ``CXoneChatError/channelConfigFailure`` if the URL cannot be parsed, most likely because
    ///     ``Environment/chatURL`` is not a valid URL.
    /// - Throws: ``URLError.badServerResponse`` if the URL Loading system received bad data from the server.
    /// - Throws: `EncodingError.invalidValue` if a non-conforming floating-point value is encountered during encoding, and the encoding strategy is `.throw`.
    /// - Throws: ``NSError`` object that indicates why the request failed
    /// - Throws: An error if any value throws an error during encoding.
    func viewPageEnded(title: String, url: String) async throws {
        guard let lastPageViewed else {
            return
        }
        guard connectionContext.chatState.isAnalyticsAvailable else {
            throw CXoneChatError.illegalChatState
        }
        
        let timeSpentInSeconds = Int(Date.provide().timeIntervalSince(lastPageViewed.timestamp))
        LogManager.trace("Reporting page view ended - \(title) Time spent: \(timeSpentInSeconds).")
        
        if lastPageViewed.title == title, lastPageViewed.url == url {
            try await trigger(
                .timeSpentOnPage,
                date: Date.provide(),
                data: TimeSpentOnPageEventDTO(url: url, title: title, timeSpentOnPage: timeSpentInSeconds)
            )
            
            self.lastPageViewed = nil
        }
    }

    /// Reports to CXone that the chat window/view has been opened by the visitor.
    ///
    /// - Throws: ``CXoneChatError/illegalChatState``if the SDK is not in the required state to trigger the method.
    /// - Throws: ``CXoneChatError/missingVisitorId``
    /// if ``ConnectionProvider/prepare(environment:brandId:channelId:)`` or ``ConnectionProvider/prepare(chatURL:socketURL:brandId:channelId:)``
    /// method was not called before triggering analytics event.
    /// - Throws: ``EncodingError.invalidValue(_:_:)`` if the given value is invalid in the current context for this format.
    /// - Throws: ``CXoneChatError/channelConfigFailure`` if the URL cannot be parsed, most likely because
    ///     environment.chatURL is not a valid URL.
    /// - Throws: ``URLError.badServerResponse`` if the URL Loading system received bad data from the server.
    /// - Throws: `EncodingError.invalidValue` if a non-conforming floating-point value is encountered during encoding, and the encoding strategy is `.throw`.
    /// - Throws: ``NSError`` object that indicates why the request failed
    /// - Throws: An error if any value throws an error during encoding.
    public func chatWindowOpen() async throws {
        guard connectionContext.chatState.isAnalyticsAvailable else {
            throw CXoneChatError.illegalChatState
        }
        
        LogManager.trace("Reporting chat window open.")
        
        try await trigger(.chatWindowOpened, date: Date.provide())
    }

    /// Reports to CXone that a conversion has occurred.
    /// - Parameters:
    ///   - type: The type of conversion. Can be any value.
    ///   - value: The value associated with the conversion (for example, unit amount). Can be any number.
    ///
    /// - Throws: ``CXoneChatError/illegalChatState``if the SDK is not in the required state to trigger the method.
    /// - Throws: ``CXoneChatError/missingVisitorId``
    /// if ``ConnectionProvider/prepare(environment:brandId:channelId:)`` or ``ConnectionProvider/prepare(chatURL:socketURL:brandId:channelId:)``
    /// method was not called before triggering analytics event.
    /// - Throws: ``EncodingError.invalidValue(_:_:)`` if the given value is invalid in the current context for this format.
    /// - Throws: ``CXoneChatError/channelConfigFailure`` if the URL cannot be parsed, most likely because
    ///     environment.chatURL is not a valid URL.
    /// - Throws: ``URLError.badServerResponse`` if the URL Loading system received bad data from the server.
    /// - Throws: `EncodingError.invalidValue` if a non-conforming floating-point value is encountered during encoding, and the encoding strategy is `.throw`.
    /// - Throws: ``NSError`` object that indicates why the request failed
    /// - Throws: An error if any value throws an error during encoding.
    public func conversion(type: String, value: Double) async throws {
        guard connectionContext.chatState.isAnalyticsAvailable else {
            throw CXoneChatError.illegalChatState
        }
        
        LogManager.trace("Reporting conversion occurred.")

        let date = Date.provide()

        try await trigger(
            .conversion,
            date: date,
            data: ConversionEventDTO(type: type, value: value, timeStamp: date)
        )
    }

    /// Reports to CXone that a proactive action was displayed to the visitor.
    /// - Parameter data: The proactive action that was displayed.
    ///
    /// - Throws: ``CXoneChatError/illegalChatState``if the SDK is not in the required state to trigger the method.
    /// - Throws: ``CXoneChatError/missingVisitorId``
    /// if ``ConnectionProvider/prepare(environment:brandId:channelId:)`` or ``ConnectionProvider/prepare(chatURL:socketURL:brandId:channelId:)``
    /// method was not called before triggering analytics event.
    /// - Throws: ``EncodingError.invalidValue(_:_:)`` if the given value is invalid in the current context for this format.
    /// - Throws: ``CXoneChatError/channelConfigFailure`` if the URL cannot be parsed, most likely because
    ///     environment.chatURL is not a valid URL.
    /// - Throws: ``URLError.badServerResponse`` if the URL Loading system received bad data from the server.
    /// - Throws: `EncodingError.invalidValue` if a non-conforming floating-point value is encountered during encoding, and the encoding strategy is `.throw`.
    /// - Throws: ``NSError`` object that indicates why the request failed
    /// - Throws: An error if any value throws an error during encoding.
    public func proactiveActionDisplay(data: ProactiveActionDetails) async throws {
        try await proactiveAction(.proactiveActionDisplayed, data: data, date: Date.provide())
    }

    /// Reports to CXone that a proactive action was successful or fails and lead to a conversion.
    ///
    /// - Parameter data: The proactive action that was successful or fails.
    ///
    /// - Throws: ``CXoneChatError/missingVisitorId``
    /// if ``ConnectionProvider/prepare(environment:brandId:channelId:)`` or ``ConnectionProvider/prepare(chatURL:socketURL:brandId:channelId:)``
    /// method was not called before triggering analytics event.
    /// - Throws: ``EncodingError.invalidValue(_:_:)`` if the given value is invalid in the current context for this format.
    /// - Throws: ``CXoneChatError/channelConfigFailure`` if the URL cannot be parsed, most likely because
    ///     environment.chatURL is not a valid URL.
    /// - Throws: ``URLError.badServerResponse`` if the URL Loading system received bad data from the server.
    /// - Throws: `EncodingError.invalidValue` if a non-conforming floating-point value is encountered during encoding, and the encoding strategy is `.throw`.
    /// - Throws: ``NSError`` object that indicates why the request failed
    /// - Throws: An error if any value throws an error during encoding.
    public func proactiveActionClick(data: ProactiveActionDetails) async throws {
        try await proactiveAction(.proactiveActionClicked, data: data, date: Date.provide())
    }
    
    /// Reports to CXone that a proactive action was successful or fails and lead to a conversion.
    ///
    /// - Parameter data: The proactive action that was successful or fails.
    ///
    /// - Throws: ``CXoneChatError/illegalChatState``if the SDK is not in the required state to trigger the method.
    /// - Throws: ``CXoneChatError/missingVisitorId``
    /// if ``ConnectionProvider/prepare(environment:brandId:channelId:)`` or ``ConnectionProvider/prepare(chatURL:socketURL:brandId:channelId:)``
    /// method was not called before triggering analytics event.
    /// - Throws: ``EncodingError.invalidValue(_:_:)`` if the given value is invalid in the current context for this format.
    /// - Throws: ``CXoneChatError/channelConfigFailure`` if the URL cannot be parsed, most likely because
    ///     environment.chatURL is not a valid URL.
    /// - Throws: ``URLError.badServerResponse`` if the URL Loading system received bad data from the server.
    /// - Throws: `EncodingError.invalidValue` if a non-conforming floating-point value is encountered during encoding, and the encoding strategy is `.throw`.
    /// - Throws: ``NSError`` object that indicates why the request failed
    /// - Throws: An error if any value throws an error during encoding.
    public func proactiveActionSuccess(_ isSuccess: Bool, data: ProactiveActionDetails) async throws {
        try await proactiveAction(
            isSuccess ? .proactiveActionSuccess : .proactiveActionFailed,
            data: data,
            date: Date.provide()
        )
    }
}

// MARK: - Private Implementation Utilities

private extension AnalyticsService {
    
    /// Check and insure that there is a current visit.  A visit is current
    /// if it exists and if the last pageView was generated less than 30 minutes
    /// ago.
    ///
    /// - Parameter date: Date of pageView event to be validated.
    /// - Returns: true iff a new visit was generated, indicating that a visitorEvent
    /// should be sent to the analytics service.
    func checkVisit(date: Date) -> Bool {
        if connectionContext.visitDetails?.expires.compare(date) != .orderedDescending {
            // if there is no visit, or the current visit has expired
            // create a new visit expiring in 30 minutes.
            connectionContext.visitDetails = CurrentVisitDetails(
                visitId: UUID.provide(),
                expires: date.addingTimeInterval(visitValidInterval)
            )

            return true
        } else {
            // if the visit is current, then we just update the visit
            // expiration date, maintaining the existing visit id.
            connectionContext.visitDetails = CurrentVisitDetails(
                visitId: connectionContext.visitId ?? UUID.provide(),
                expires: date.addingTimeInterval(visitValidInterval)
            )

            return false
        }
    }

    /// Generate a ProactiveAction based event.
    /// - Parameter type: type of proactive action based event.  Only `.proactiveActionDisplayed`, `.proactiveActionClicked`,
    ///     `.proactiveActionSuccess`, or `.proactiveActionFailed` should be passed.
    /// - Throws: ``CXoneChatError/missingVisitorId``
    /// if ``ConnectionProvider/prepare(environment:brandId:channelId:)`` or ``ConnectionProvider/prepare(chatURL:socketURL:brandId:channelId:)``
    /// method was not called before triggering analytics event.
    /// - Throws: ``EncodingError.invalidValue(_:_:)`` if the given value is invalid in the current context for this format.
    /// - Throws: ``CXoneChatError/channelConfigFailure`` if the URL cannot be parsed, most likely because
    ///     environment.chatURL is not a valid URL.
    /// - Throws: ``URLError.badServerResponse`` if the URL Loading system received bad data from the server.
    /// - Throws: `EncodingError.invalidValue` if a non-conforming floating-point value is encountered during encoding, and the encoding strategy is `.throw`.
    /// - Throws: ``NSError`` object that indicates why the request failed
    /// - Throws: An error if any value throws an error during encoding.
    func proactiveAction(_ type: AnalyticsEventType, data: ProactiveActionDetails, date: Date) async throws {
        guard connectionContext.chatState.isAnalyticsAvailable else {
            throw CXoneChatError.illegalChatState
        }
        
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

    /// Trigger an analytics event by sending it to the analytics service.
    ///
    /// - Parameters:
    ///    - type: type of event to trigger
    ///    - date: event date to set
    ///    - data: extra data defined by ``type``
    ///    - fun: function name for logging purpose
    ///    - file: file name for logging purpose
    ///    - line: line number for logging purpose
    
    /// - Throws: ``CXoneChatError/missingVisitorId``
    /// if ``ConnectionProvider/prepare(environment:brandId:channelId:)`` or ``ConnectionProvider/prepare(chatURL:socketURL:brandId:channelId:)``
    /// method was not called before triggering analytics event.
    /// - Throws: ``EncodingError.invalidValue(_:_:)`` if the given value is invalid in the current context for this format.
    /// - Throws: ``CXoneChatError/channelConfigFailure`` if the URL cannot be parsed, most likely because
    ///     environment.chatURL is not a valid URL.
    /// - Throws: ``URLError.badServerResponse`` if the URL Loading system received bad data from the server.
    /// - Throws: `EncodingError.invalidValue` if a non-conforming floating-point value is encountered during encoding, and the encoding strategy is `.throw`.
    /// - Throws: ``NSError`` object that indicates why the request failed
    /// - Throws: An error if any value throws an error during encoding.
    func trigger(
        _ type: AnalyticsEventType,
        date: Date,
        data: Encodable = [String: String](),
        file: StaticString = #file,
        line: UInt = #line
    ) async throws {
        guard let visitorId = visitorId else {
            throw CXoneChatError.missingVisitorId
        }

        let data = try AnalyticsEventDTO(
            type: type,
            connection: connectionContext,
            createdAt: date,
            data: data
        )

        try await post(event: data, brandId: connectionContext.brandId, visitorId: visitorId, file: file, line: line)
    }

    /// Post an event to the web-analytics service with specified brand and visitor ids.
    ///
    /// - Parameters:
    ///    - event: event to send
    ///    - brandId: brand to target
    ///    - visitorId: visitorId to target
    ///    - file: file name for logging purpose
    ///    - line: line number for logging purpose
    ///
    /// - Throws: ``CXoneChatError/channelConfigFailure`` if the URL cannot be parsed, most likely because
    ///     environment.chatURL is not a valid URL.
    /// - Throws: ``URLError.badServerResponse`` if the URL Loading system received bad data from the server.
    /// - Throws: `EncodingError.invalidValue` if a non-conforming floating-point value is encountered during encoding, and the encoding strategy is `.throw`.
    /// - Throws:``NSError`` object that indicates why the request failed
    /// - Throws: An error if any value throws an error during encoding.
    func post(
        event: AnalyticsEventDTO,
        brandId: Int,
        visitorId: UUID,
        file: StaticString = #file,
        line: UInt = #line
    ) async throws {
        guard let url = connectionContext.environment.webAnalyticsURL(brandId: brandId) / "visitors" / visitorId / "events" else {
            throw CXoneChatError.channelConfigFailure
        }

        var request = URLRequest(url: url, method: .post, contentType: "application/json")
        request.httpBody = try jsonEncoder.encode(event)

        try await connectionContext.session.fetch(for: request, file: file, line: line)
    }

}
