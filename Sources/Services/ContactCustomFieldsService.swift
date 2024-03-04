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

class ContactCustomFieldsService: ContactCustomFieldsProvider {
    
    // MARK: - Properties
    
    private var channelConfig: ChannelConfigurationDTO {
        socketService.connectionContext.channelConfig
    }
    
    var socketService: SocketService
    var eventsService: EventsService
    let dateProvider: DateProvider
    
    // MARK: - Protocol Properties
    
    var contactFields = [UUID: [CustomFieldDTOType]]()
    
    // MARK: - Init
    
    init(socketService: SocketService, eventsService: EventsService, dateProvider: DateProvider) {
        self.socketService = socketService
        self.eventsService = eventsService
        self.dateProvider = dateProvider
    }
    
    // MARK: - Implementation
    
    func get(for threadId: UUID) -> [CustomFieldType] {
        contactFields[threadId]?.map(CustomFieldTypeMapper.map) ?? []
    }
    
    /// - Throws: ``CXoneChatError/notConnected`` if an attempt was made to use a method without connecting first.
    ///     Make sure you call the `connect` method first.
    /// - Throws: ``CXoneChatError/customerAssociationFailure`` if the SDK could not get customer identity and it may not have been set.
    /// - Throws: ``EncodingError.invalidValue(_:_:)`` if the given value is invalid in the current context for this format.
    func set(_ customFields: [String: String], for threadId: UUID) throws {
        LogManager.trace("Setting a custom fields on a contact (specific thread).")

        try socketService.checkForConnection()

        var mappedCustomFields = customFields.mapDefinitions(
            channelConfig.contactCustomFieldDefinitions,
            currentDate: dateProvider.now,
            error: .unknownCaseCustomFields
        )
        
        if var contactFields = contactFields[threadId] {
            contactFields.merge(with: mappedCustomFields)
            mappedCustomFields = contactFields
        }
        
        self.contactFields[threadId] = mappedCustomFields
        
        if let id = socketService.connectionContext.contactId {
            let data = try eventsService.create(
                .setContactCustomFields,
                with: .setContactCustomFieldsData(
                    SetContactCustomFieldsEventDataDTO(
                        thread: ThreadDTO(idOnExternalPlatform: threadId, threadName: nil),
                        customFields: mappedCustomFields.compactMap(CustomFieldDTO.init),
                        contactId: id
                    )
                )
            )
            
            socketService.send(message: data.utf8string)
        }
    }
    
    // MARK: - Internal methods
    
    func updateFields(_ fields: [CustomFieldDTO], for threadId: UUID) {
        let mappedFields = fields.compactMap { customField -> CustomFieldDTOType? in
            guard var newField = channelConfig.contactCustomFieldDefinitions.first(where: { $0.ident == customField.ident }) else {
                LogManager.warning("Unable to get definition for case custom field. Custom field with ident: \(customField.ident) will be ignored.")
                return nil
            }
            
            newField.updateValue(customField.value)
            newField.updateUpdatedAt(customField.updatedAt)
            
            return newField
        }
        
        if contactFields[threadId] == nil {
            contactFields[threadId] = mappedFields
        } else {
            contactFields[threadId]?.merge(with: mappedFields)
        }
    }
}
