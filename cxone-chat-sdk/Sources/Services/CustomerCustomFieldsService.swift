import Foundation

final class CustomerCustomFieldsService: CustomerCustomFieldsProvider {
    
    // MARK: - Properties
    
    private var channelConfig: ChannelConfigurationDTO {
        socketService.connectionContext.channelConfig
    }
    
    var socketService: SocketService
    var eventsService: EventsService
    let dateProvider: DateProvider
    
    // MARK: - Protocol Properties
    
    var customerFields = [CustomFieldDTOType]()
    
    // MARK: - Init
    
    init(socketService: SocketService, eventsService: EventsService, dateProvider: DateProvider) {
        self.socketService = socketService
        self.eventsService = eventsService
        self.dateProvider = dateProvider
    }
    
    // MARK: - Implementation
    
    func get() -> [CustomFieldType] {
        customerFields.map(CustomFieldTypeMapper.map)
    }
    
    /// - Throws: ``CXoneChatError/notConnected`` if an attempt was made to use a method without connecting first.
    ///     Make sure you call the `connect` method first.
    /// - Throws: ``CXoneChatError/customerAssociationFailure`` if the SDK could not get customer identity and it may not have been set.
    /// - Throws: ``EncodingError.invalidValue(_:_:)`` if the given value is invalid in the current context for this format.
    func set(_ customFields: [String: String]) throws {
        LogManager.trace("Setting custom fields for a contact (persists across all threads involving the customer).")
        
        try socketService.checkForConnection()
        
        let mappedCustomFields = customFields.mapDefinitions(
            channelConfig.customerCustomFieldDefinitions,
            currentDate: dateProvider.now,
            error: .unknownCustomerCustomFields
        )
        customerFields.merge(with: mappedCustomFields)
        
        let data = try eventsService.create(
            .setCustomerCustomFields,
            with: .setCustomerCustomFieldData(ContactCustomFieldsDataDTO(customFields: mappedCustomFields.compactMap(CustomFieldDTO.init)))
        )
        
        socketService.send(message: data.utf8string)
    }
    
    // MARK: - Internal methods
    
    func updateFields(_ fields: [CustomFieldDTO]) {
        let mappedFields = fields.compactMap { customField -> CustomFieldDTOType? in
            guard var newField = channelConfig.customerCustomFieldDefinitions.first(where: { $0.ident == customField.ident }) else {
                LogManager.warning("Unable to get definition for customer custom field. Custom field with ident: \(customField.ident) will be ignored.")
                return nil
            }
            
            newField.updateValue(customField.value)
            newField.updateUpdatedAt(customField.updatedAt)
            
            return newField
        }
        
        if customerFields.isEmpty {
            customerFields = mappedFields
        } else {
            customerFields.merge(with: mappedFields)
        }
    }
}
