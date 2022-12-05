import Foundation


final class CustomerCustomFieldsService: CustomerCustomFieldsProvider {
    
    // MARK: - Properties
    
    var customerFields = [String: String]()
    
    var socketService: SocketService
    var eventsService: EventsService
    
    
    // MARK: - init
    
    init(socketService: SocketService, eventsService: EventsService) {
        self.socketService = socketService
        self.eventsService = eventsService
    }
    
    
    // MARK: - Implementation
    
    func get() -> [String: String] {
        customerFields
    }
    
    
    func set(_ customFields: [String: String]) throws {
        LogManager.trace("Setting custom fields for a contact (persists across all threads involving the customer).")

        try socketService.checkForConnection()

        customerFields = customFields
        
        let customFields = customFields.map { CustomFieldDTO(ident: $0.key, value: $0.value) }
        let data = try eventsService.create(
            .setCustomerCustomFields,
            with: .setCustomerCustomFieldData(.init(customFields: customFields))
        )
        
        socketService.send(message: data.utf8string)
    }
}
