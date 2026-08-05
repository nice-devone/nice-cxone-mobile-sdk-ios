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

import CXoneGuideUtility
import Foundation

final class ContactCustomFieldsService: Sendable {

    // MARK: - Properties

    private var channelConfig: ChannelConfigurationDTO {
        socketService.connectionContext.channelConfig
    }

    private let _contactFields = SafeAccessContainer<[String: [CustomFieldDTO]]>([:])
    
    let socketService: SocketService
    let eventsService: EventsService

    var contactFields: [String: [CustomFieldDTO]] {
        get { _contactFields.content }
        set {
            _contactFields.mutate { content in
                content = newValue
            }
        }
    }
    
    // MARK: - Init
    
    init(socketService: SocketService, eventsService: EventsService) {
        self.socketService = socketService
        self.eventsService = eventsService
    }
}

// MARK: - ContactCustomFieldsProvider
    
extension ContactCustomFieldsService: ContactCustomFieldsProvider {
    
    func get(for threadId: String) -> [String: String] {
        Dictionary(uniqueKeysWithValues: contactFields[threadId]?.lazy.map { ($0.ident, $0.value) } ?? [])
    }
    
    func set(_ customFields: [String: String], for threadId: String) async throws {
        LogManager.trace("Setting a custom fields on a contact (specific thread).")

        try socketService.checkForConnection()
        
        updateFields(customFields.map { CustomFieldDTO(ident: $0.key, value: $0.value, updatedAt: Date()) }, for: threadId)
        
        if let id = socketService.connectionContext.contactId {
            let data = try eventsService.create(
                .setContactCustomFields,
                with: .setContactCustomFieldsData(
                    SetContactCustomFieldsEventDataDTO(
                        thread: ThreadDTO(idOnExternalPlatform: threadId, threadName: nil),
                        customFields: contactFields[threadId] ?? [],
                        contactId: id
                    )
                )
            )
            
            try await socketService.send(data: data)
        }
    }
}

// MARK: - Internal methods

extension ContactCustomFieldsService {
    
    func updateFields(_ fields: [CustomFieldDTO], for threadId: String) {
        let fields = fields.filter { newField in
            // Check if field exists in prechat survey configuration
            // If not found, include the field without validation
            guard let prechatDefinition = channelConfig.prechatSurvey?.customFields.first(where: { $0.type.ident == newField.ident }) else {
                return true
            }
            
            let isValueEmpty = newField.value.isEmpty
            let isValueIdentifier = prechatDefinition.type.isValueIdentifier(newField.value)
            
            if prechatDefinition.isRequired {
                return prechatDefinition.type.shouldCheckValue
                    ? isValueIdentifier && !isValueEmpty
                    : !isValueEmpty
            } else {
                return prechatDefinition.type.shouldCheckValue
                    ? isValueIdentifier
                    : true
            }
        }
        
        if contactFields[threadId] == nil {
            contactFields[threadId] = fields
        } else {
            contactFields[threadId]?.merge(with: fields)
        }
    }
    
    func clearStoredData() {
        LogManager.info("Removing stored data for contact custom fields service")
        
        contactFields.removeAll()
    }
}

// MARK: - Helpers

private extension CustomFieldDTOType {

    var shouldCheckValue: Bool {
        switch self {
        case .selector, .hierarchical:
            true
        default:
            false
        }
    }
}
