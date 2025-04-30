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

class WelcomeMessageManager {
    
    // MARK: - Properties
    
    private static let fallbackDelimiter = "|"
    private static let openingParam = "{{"
    private static let closingParam = "}}"
    private static let fallbackMessageIndicator = "{{fallbackMessage|"
    
    // MARK: - Methods
    
    /// Parses a raw welcome message with contact and customer custom fields and customer credentials.
    ///
    /// The raw message might take several forms:
    ///   - without parameters - plain text,
    ///     ```swift
    ///     // Without parameters
    ///     let message = "Dear customer, we have a 5% discout for you!"
    ///     let customer = CustomerIdentityDTO(idOnExternalPlatform: UUID().uuidString, firstName: "", lastName: "")
    ///     let parsedMessage = welcomeMessageManager.parse(message, contactFields: [:], customerFields: [:], customer: customer)
    ///
    ///     parsedMessage // "Dear customer, we have a 5% discout for you!"
    ///     ```
    ///   - parameterized without fallback - text contain parameters inside special characters, `"{{customer.fullName}}"`
    ///     ```swift
    ///     // Parameterized without fallback
    ///     let message = "Dear {{customer.fullName}}, we have a {{contact.customFields.discount}} discout for you!"
    ///     let customer = CustomerIdentityDTO(idOnExternalPlatform: UUID().uuidString, firstName: "John", lastName: "Doe")
    ///     let parsedMessage = welcomeMessageManager.parse(
    ///         message,
    ///         contactFields: ["contact.customFields.discount": "10 %"],
    ///         customerFields: [:],
    ///         customer: customer
    ///     )
    ///
    ///     parsedMessage // "Dear John Doe, we have a 10 % discout for you!"
    ///     ```
    ///   - parameterized with fallback - text contain parameters inside special characters with fallback values, `"{{customer.fullName|customer}}"`
    ///     ```swift
    ///     // Parameterized with fallback
    ///     let message = "Dear {{customer.fullName|customer}}, we have a {{contact.customFields.discount|5%}} discout for you!"
    ///     let customer = CustomerIdentityDTO(idOnExternalPlatform: UUID().uuidString, firstName: "John", lastName: "Doe")
    ///     let parsedMessage = welcomeMessageManager.parse(message, contactFields: [:], customerFields: [:], customer: customer)
    ///
    ///     parsedMessage // "Dear John Doe, we have a 5% discout for you!"
    ///     ```
    ///   - fallback message - text contain fallback message in case any parameter was not be able to replaced with a value.
    ///   ```swift
    ///     // Fallback message
    ///     let message = "Dear {{customer.fullName}}, we have a {{contact.customFields.discount}} discout for you!"
    ///         + "{{fallbackMessage|Dear customer, we have a special deal for you!}}"
    ///     let customer = CustomerIdentityDTO(idOnExternalPlatform: UUID().uuidString, firstName: "", lastName: "")
    ///     let parsedMessage = welcomeMessageManager.parse(message, contactFields: [:], customerFields: [:], customer: customer)
    ///
    ///     parsedMessage // "Dear customer, we have a special deal for you!"
    /// ```
    /// - Parameters:
    ///   - message: The message to be parsed.
    ///   - contactFields: The list of contact custom fields (related to existing thread).
    ///   - customerFields: The list of customer custom fields (related to customer).
    ///   - customer: The customer identity.
    /// - Warning: In case message contains parameter segment without fallback and no parameter,
    ///     via `contactFields`, `customerFields` or `customer` entity, is provided,
    ///     final message would contain non parsed parameter segment, e.g. `Welcome {{customer.fullName}}!`
    /// - Returns: The parsed welcome message.
    func parse(_ message: String, contactFields: [CustomFieldDTO], customerFields: [CustomFieldDTO], customer: CustomerIdentityDTO) -> String {
        guard message.contains(Self.openingParam), message.contains(Self.closingParam) else {
            return message
        }
        
        let components = message.components(separatedBy: Self.fallbackMessageIndicator)
        let message = components[0]
        let fallbackMessage = components[safe: 1]?.mapNonEmpty { $0.substring(to: Self.closingParam) ?? $0 }
        
        var parameters = contactFields
        parameters.merge(with: customerFields)
        parameters.merge(with: customer.credentialParameters())
        
        var result = message
        
        message
            .filterVariables()
            .forEach { element in
                if element.contains(Self.fallbackDelimiter) {
                    if let field = parameters.getValidCustomField(for: element.substring(from: Self.openingParam, to: Self.fallbackDelimiter)) {
                        result = result.replacingOccurrences(of: element, with: field.value)
                    } else if let fallbackValue = element.substring(from: Self.fallbackDelimiter, to: Self.closingParam) {
                        result = result.replacingOccurrences(of: element, with: fallbackValue)
                    }
                } else {
                    if let field = parameters.getValidCustomField(for: element.substring(from: Self.openingParam, to: Self.closingParam)) {
                        result = result.replacingOccurrences(of: element, with: field.value)
                    }
                }
            }
        
        if result.contains(Self.openingParam), let fallbackMessage {
            return fallbackMessage
        } else {
            return result
        }
    }
}

// MARK: - Helpers

private extension [CustomFieldDTO] {
    
    func getValidCustomField(for ident: String?) -> Element? {
        guard let field = first(where: { $0.ident == ident }) else {
            return nil
        }
        
        return field.value.trimmingCharacters(in: .whitespaces).isEmpty ? nil : field
    }
}

private extension String {
    
    func filterVariables() -> [String] {
        var text = self
        var result = [String]()
        
        while text.substring(from: "{{", to: "}}") != nil {
            guard let substring = text.substring(from: "{{", to: "}}") else {
                continue
            }
            
            let newValue = "{{\(substring)}}"
            text = text.replacingOccurrences(of: newValue, with: "")
            result.append(newValue)
        }
        
        return result
    }
}

private extension CustomerIdentityDTO {
    
    func credentialParameters() -> [CustomFieldDTO] {
        let firstName = self.firstName ?? ""
        let lastName = self.lastName ?? ""
        
        return [
            CustomFieldDTO(ident: "customer.firstName", value: firstName, updatedAt: Date.provide()),
            CustomFieldDTO(ident: "customer.lastName", value: lastName, updatedAt: Date.provide()),
            CustomFieldDTO(ident: "customer.fullName", value: "\(firstName) \(lastName)", updatedAt: Date.provide())
        ]
    }
}
