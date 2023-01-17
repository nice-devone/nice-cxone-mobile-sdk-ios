import Foundation


class ContactCustomFieldsService: ContactCustomFieldsProvider {
    
    // MARK: - Properties
    
    var contactFields = [UUID: [CustomFieldDTO]]()
    
    var socketService: SocketService
    var eventsService: EventsService
    
    
    // MARK: - init
    
    init(socketService: SocketService, eventsService: EventsService) {
        self.socketService = socketService
        self.eventsService = eventsService
    }
    
    
    // MARK: - Implementation
    
    func get(for threadId: UUID) -> [String: String] {
        contactFields
            .first { $0.key == threadId }?
            .value.toDictionary() ?? [:]
    }
    
    func set(_ customFields: [String: String], for threadId: UUID) throws {
        LogManager.trace("Setting a custom fields on a contact (specific thread).")

        try socketService.checkForConnection()

        let customFields = customFields.map { CustomFieldDTO(ident: $0.key, value: $0.value, updatedAt: Date()) }
        contactFields[threadId] = customFields
        
        if let id = socketService.connectionContext.contactId {
            let data = try eventsService.create(
                .setCustomerContactCustomFields,
                with: .setContactCustomFieldsData(
                    .init(
                        thread: .init(id: nil, idOnExternalPlatform: threadId, threadName: nil),
                        customFields: customFields,
                        contactId: id
                    )
                )
            )
            
            socketService.send(message: data.utf8string)
        }
    }
    
    
    // MARK: - Internal methods
    
    func updateFields(_ fields: [CustomFieldDTO], for threadId: UUID) {
        guard self.contactFields[threadId] != nil else {
            self.contactFields[threadId] = fields
            return
        }
        
        contactFields[threadId]?.update(with: fields)
    }
}
