import Foundation


class AnalyticsService: AnalyticsProvider {
    
    // MARK: - Properties
    
    var visitorId: UUID? {
        get { connectionContext.visitorId }
        set { connectionContext.visitorId = newValue }
    }
    
    private let jsonEncoder = JSONEncoder()
    
    let socketService: SocketService
    let eventsService: EventsService
    
    var connectionContext: ConnectionContext {
        get { socketService.connectionContext }
        set { socketService.connectionContext = newValue }
    }
    
    
    // MARK: - Init
    
    init(socketService: SocketService, eventsService: EventsService) {
        self.socketService = socketService
        self.eventsService = eventsService
    }
    
    
    // MARK: - Implementation
    
    func viewPage(title: String, uri: String) throws {
        LogManager.trace("Reporting page view - \(title).")

        try socketService.checkForConnection()
        
        let data = try jsonEncoder.encode(
            StoreVisitorEventsDTO(
                action: .chatWindowEvent,
                eventId: UUID(),
                payload: getVisitorEventsPayload(eventType: .pageView, data: .pageViewData(.init(url: uri, title: title)))
            )
        )
        
        socketService.send(message: data.utf8string)
    }
    
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
    
    func conversion(type: String, value: Double) throws {
        LogManager.trace("Reporting conversion occurred.")

        try socketService.checkForConnection()
        
        let data = try jsonEncoder.encode(
            StoreVisitorEventsDTO(
                action: .chatWindowEvent,
                eventId: UUID(),
                payload: getVisitorEventsPayload(
                    eventType: .conversion,
                    data: .conversionData(.init(type: type, value: value, timeWithMilliseconds: Date().iso8601withFractionalSeconds))
                )
            )
        )
        
        socketService.send(message: data.utf8string)
    }
    
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
    
    func setVisitor() throws {
        LogManager.trace("Setting visitor.")
        
        guard let visitorId = visitorId else {
            throw CXoneChatError.unsupportedChannelConfig
        }
        
        let payload = StoreVisitorEventsPayloadDTO(
            eventType: .storeVisitor,
            brand: .init(id: connectionContext.brandId),
            visitorId: LowerCaseUUID(uuid: visitorId),
            id: LowerCaseUUID(uuid: connectionContext.destinationId),
            data: .storeVisitorPayload(
                .init(
                    customerIdentity: connectionContext.customer,
                    browserFingerprint: .init(deviceToken: connectionContext.deviceToken),
                    journey: nil,
                    customVariables: nil
                )
            ),
            channel: .init(id: connectionContext.channelId)
        )
        
        let data = try jsonEncoder.encode(StoreVisitorEventsDTO( action: .chatWindowEvent, eventId: UUID(), payload: payload))
        
        socketService.send(message: data.utf8string, shouldCheck: false)
    }
}


// MARK: - Mappers

private extension AnalyticsService {

    func getVisitorEventsPayload(eventType: VisitorEventType, data: VisitorEventDataType?) throws -> StoreVisitorEventsPayloadDTO {
        guard let visitorId = visitorId else {
            throw CXoneChatError.missingParameter("visitorId")
        }
        
        return .init(
            eventType: .storeVisitorEvents,
            brand: .init(id: connectionContext.brandId),
            visitorId: LowerCaseUUID(uuid: visitorId),
            id: LowerCaseUUID(uuid: connectionContext.destinationId),
            data: .visitorEvent(
                .init(
                    visitorEvents: [
                        .init(
                            id: LowerCaseUUID(uuid: UUID()),
                            type: eventType,
                            createdAtWithMilliseconds: Date().iso8601withFractionalSeconds,
                            data: data
                        )
                    ]
                )
            ),
            channel: .init(id: connectionContext.channelId)
        )
    }
}
