import Foundation


final class CustomerCustomFieldsService: CustomerCustomFieldsProvider {
    
    // MARK: - Properties
    
    var customerFields = [CustomFieldDTO]()
    
    var socketService: SocketService
    var eventsService: EventsService
    
    
    // MARK: - init
    
    init(socketService: SocketService, eventsService: EventsService) {
        self.socketService = socketService
        self.eventsService = eventsService
    }
    
    
    // MARK: - Implementation
    
    func get() -> [String: String] {
        customerFields.toDictionary()
    }
    
    func set(_ customFields: [String: String]) throws {
        LogManager.trace("Setting custom fields for a contact (persists across all threads involving the customer).")
        
        try socketService.checkForConnection()
        
        customerFields = customFields.map { CustomFieldDTO(ident: $0.key, value: $0.value, updatedAt: Date()) }
        
        let data = try eventsService.create(
            .setCustomerCustomFields,
            with: .setCustomerCustomFieldData(.init(customFields: customerFields))
        )
        
        socketService.send(message: data.utf8string)
    }
    
    
    // MARK: - Internal methods
    
    func updateFields(_ fields: [CustomFieldDTO]) {
        guard !customerFields.isEmpty else {
            self.customerFields = fields
            return
        }
        
        customerFields.update(with: fields)
    }
}
