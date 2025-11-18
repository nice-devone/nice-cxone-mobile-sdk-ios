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

final class CustomerCustomFieldsService {
    
    // MARK: - Properties
    
    var socketService: SocketService
    var eventsService: EventsService

    // MARK: - Protocol Properties
    
    var customerFields = [CustomFieldDTO]()
    
    // MARK: - Init
    
    init(socketService: SocketService, eventsService: EventsService) {
        self.socketService = socketService
        self.eventsService = eventsService
    }
}

// MARK: - CustomerCustomFieldsProvider

extension CustomerCustomFieldsService: CustomerCustomFieldsProvider {

    func get() -> [String: String] {
        Dictionary(uniqueKeysWithValues: customerFields.lazy.map { ($0.ident, $0.value) })
    }
    
    /// - Throws: ``CXoneChatError/notConnected`` if an attempt was made to use a method without connecting first.
    ///     Make sure you call the `connect` method first.
    /// - Throws: ``CXoneChatError/customerAssociationFailure`` if the SDK could not get customer identity and it may not have been set.
    /// - Throws: ``CXoneChatError/invalidData`` when the Data object cannot be successfully converted to a valid UTF-8 string
    /// - Throws: ``EncodingError.invalidValue(_:_:)`` if the given value is invalid in the current context for this format.
    func set(_ customFields: [String: String]) async throws {
        LogManager.trace("Setting custom fields for a contact (persists across all threads involving the customer).")
        
        try socketService.checkForConnection()
        
        updateFields(customFields.map { CustomFieldDTO(ident: $0.key, value: $0.value, updatedAt: Date()) })
        
        let data = try eventsService.create(
            .setCustomerCustomFields,
            with: .setCustomerCustomFieldData(ContactCustomFieldsDataDTO(customFields: customerFields))
        )
        
        try await socketService.send(data: data)
    }
    
    // MARK: - Internal methods
    
    func updateFields(_ fields: [CustomFieldDTO]) {
        let fields = fields.filter { !$0.value.isEmpty }
        
        if customerFields.isEmpty {
            customerFields = fields
        } else {
            customerFields.merge(with: fields)
        }
    }
}
