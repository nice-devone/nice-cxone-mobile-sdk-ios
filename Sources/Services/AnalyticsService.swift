import Foundation


class AnalyticsService: AnalyticsProvider {
    
    // MARK: - Properties
    
    private let jsonEncoder = JSONEncoder()
    
    let socketService: SocketService
    
    var connectionContext: ConnectionContext {
        get { socketService.connectionContext }
        set { socketService.connectionContext = newValue }
    }
    
    
    // MARK: - Protocol Properties
    
    var visitorId: UUID? {
        get { connectionContext.visitorId }
        set { connectionContext.visitorId = newValue }
    }
    
    
    // MARK: - Init
    
    init(socketService: SocketService) {
        self.socketService = socketService
    }
    
    
    // MARK: - Implementation
    
    /// - Throws: ``CXoneChatError/notConnected`` if an attempt was made to use a method without connecting first.
    ///     Make sure you call the `connect` method first.
    /// - Throws: ``EncodingError.invalidValue(_:_:)`` if the given value is invalid in the current context for this format.
    func viewPage(title: String, uri: String) throws {
        LogManager.trace("Reporting page view - \(title).")

        try socketService.checkForConnection()
        
        let data = try jsonEncoder.encode(
            StoreVisitorEventsDTO(
                action: .chatWindowEvent,
                eventId: UUID(),
                payload: getVisitorEventsPayload(eventType: .pageView, data: .pageViewData(PageViewData(url: uri, title: title)))
            )
        )
        
        socketService.send(message: data.utf8string)
    }
    
    /// - Throws: ``CXoneChatError/notConnected`` if an attempt was made to use a method without connecting first.
    ///     Make sure you call the `connect` method first.
    /// - Throws: ``EncodingError.invalidValue(_:_:)`` if the given value is invalid in the current context for this format.
    func chatWindowOpen() throws {
        LogManager.trace("Reporting chat window open.")

        try socketService.checkForConnection()

        let data = try jsonEncoder.encode(
            StoreVisitorEventsDTO(
                action: .chatWindowEvent,
                eventId: UUID(),
                payload: getVisitorEventsPayload(eventType: .chatWindowOpened, data: nil)
            )
        )
        
        socketService.send(message: data.utf8string)
    }
    
    /// - Throws: ``CXoneChatError/notConnected`` if an attempt was made to use a method without connecting first.
    ///     Make sure you call the `connect` method first.
    /// - Throws: ``CXoneChatError/customerVisitorAssociationFailure`` if the customer could not be associated with a visitor.
    /// - Throws: ``EncodingError.invalidValue(_:_:)`` if the given value is invalid in the current context for this format.
    func visit() throws {
        LogManager.trace("Reporting app visit.")
        
        try setVisitor()

        try socketService.checkForConnection()
        
        let data = try jsonEncoder.encode(
            StoreVisitorEventsDTO(
                action: .chatWindowEvent,
                eventId: UUID(),
                payload: getVisitorEventsPayload(eventType: .visitorVisit, data: nil)
            )
        )
        
        socketService.send(message: data.utf8string, shouldCheck: false)
    }
    
    /// - Throws: ``CXoneChatError/notConnected`` if an attempt was made to use a method without connecting first.
    ///     Make sure you call the `connect` method first.
    /// - Throws: ``EncodingError.invalidValue(_:_:)`` if the given value is invalid in the current context for this format.
    func conversion(type: String, value: Double) throws {
        LogManager.trace("Reporting conversion occurred.")

        try socketService.checkForConnection()
        
        let data = try jsonEncoder.encode(
            StoreVisitorEventsDTO(
                action: .chatWindowEvent,
                eventId: UUID(),
                payload: getVisitorEventsPayload(
                    eventType: .conversion,
                    data: .conversionData(ConversionData(type: type, value: value, timeWithMilliseconds: Date().iso8601withFractionalSeconds))
                )
            )
        )
        
        socketService.send(message: data.utf8string)
    }
    
    /// - Throws: ``CXoneChatError/notConnected`` if an attempt was made to use a method without connecting first.
    ///     Make sure you call the `connect` method first.
    /// - Throws: ``EncodingError.invalidValue(_:_:)`` if the given value is invalid in the current context for this format.
    func customVisitorEvent(data: VisitorEventDataType) throws {
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
    
    /// - Throws: ``CXoneChatError/notConnected`` if an attempt was made to use a method without connecting first.
    ///     Make sure you call the `connect` method first.
    /// - Throws: ``EncodingError.invalidValue(_:_:)`` if the given value is invalid in the current context for this format.
    func proactiveActionDisplay(data: ProactiveActionDetails) throws {
        LogManager.trace("Reporting proactive action was displayed to the visitor.")

        try socketService.checkForConnection()
        
        let data = try jsonEncoder.encode(
            StoreVisitorEventsDTO(
                action: .chatWindowEvent,
                eventId: UUID(),
                payload: getVisitorEventsPayload(eventType: .proactiveActionDisplayed, data: .proactiveActionData(data))
            )
        )
        
        socketService.send(message: data.utf8string)
    }
    
    /// - Throws: ``CXoneChatError/notConnected`` if an attempt was made to use a method without connecting first.
    ///     Make sure you call the `connect` method first.
    /// - Throws: ``EncodingError.invalidValue(_:_:)`` if the given value is invalid in the current context for this format.
    func proactiveActionClick(data: ProactiveActionDetails) throws {
        LogManager.trace("Reporting proactive action was clicked or acted upon the visitor.")

        try socketService.checkForConnection()
        
        let data = try jsonEncoder.encode(
            StoreVisitorEventsDTO(
                action: .chatWindowEvent,
                eventId: UUID(),
                payload: getVisitorEventsPayload(eventType: .proactiveActionClicked, data: .proactiveActionData(data))
            )
        )
        
        socketService.send(message: data.utf8string)
    }
    
    /// - Throws: ``CXoneChatError/notConnected`` if an attempt was made to use a method without connecting first.
    ///     Make sure you call the `connect` method first.
    /// - Throws: ``EncodingError.invalidValue(_:_:)`` if the given value is invalid in the current context for this format.
    func proactiveActionSuccess(_ isSuccess: Bool, data: ProactiveActionDetails) throws {
        LogManager.trace("Reporting proactive actions was successful and lead to a conversion.")

        try socketService.checkForConnection()
        
        let data = try jsonEncoder.encode(
            StoreVisitorEventsDTO(
                action: .chatWindowEvent,
                eventId: UUID(),
                payload: getVisitorEventsPayload(
                    eventType: isSuccess ? .proactiveActionSuccess : .proactiveActionFailed,
                    data: .proactiveActionData(data)
                )
            )
        )
        
        socketService.send(message: data.utf8string)
    }
    
    
    // MARK: - Internal methods
    
    /// - Throws: ``CXoneChatError/customerVisitorAssociationFailure`` if the customer could not be associated with a visitor.
    /// - Throws: ``EncodingError.invalidValue(_:_:)`` if the given value is invalid in the current context for this format.
    func setVisitor() throws {
        LogManager.trace("Setting visitor.")
        
        guard let visitorId = visitorId else {
            throw CXoneChatError.customerVisitorAssociationFailure
        }
        
        let payload = StoreVisitorEventsPayloadDTO(
            eventType: .storeVisitor,
            brand: BrandDTO(id: connectionContext.brandId),
            visitorId: LowerCaseUUID(uuid: visitorId),
            id: LowerCaseUUID(uuid: connectionContext.destinationId),
            data: .storeVisitorPayload(
                VisitorDTO(
                    customerIdentity: connectionContext.customer,
                    browserFingerprint: DeviceFingerprintDTO(deviceToken: connectionContext.deviceToken),
                    journey: nil,
                    customVariables: nil
                )
            ),
            channel: ChannelIdentifierDTO(id: connectionContext.channelId)
        )
        
        let data = try jsonEncoder.encode(StoreVisitorEventsDTO( action: .chatWindowEvent, eventId: UUID(), payload: payload))
        
        socketService.send(message: data.utf8string, shouldCheck: false)
    }
}


// MARK: - Mappers

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
                            createdAtWithMilliseconds: Date().iso8601withFractionalSeconds,
                            data: data
                        )
                    ]
                )
            ),
            channel: ChannelIdentifierDTO(id: connectionContext.channelId)
        )
    }
}
