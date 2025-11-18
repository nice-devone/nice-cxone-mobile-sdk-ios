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

/// Strongly-typed payload for an inactivity popup inside a plugin message
struct MessageInactivityPopupDTO: Equatable {
    
    // MARK: - Properties

    /// Element identifier of the inactivity popup container.
    let id: UUID

    /// The title element of the popup.
    let title: InactivityPopupTitleElementDTO
    
    /// The body text elements of the popup
    let body: InactivityPopupTextElementDTO
    
    /// The call to action text element.
    let callToAction: InactivityPopupTextElementDTO
    
    /// The countdown element showing time remaining.
    let countdown: InactivityPopupCountdownElementDTO
    
    /// The button to expire the session.
    let expireButton: InactivityPopupButtonElementDTO
    
    /// The button to refresh the session.
    let refreshButton: InactivityPopupButtonElementDTO
}

// MARK: - Decodable

extension MessageInactivityPopupDTO: Decodable {
    
    enum CodingKeys: String, CodingKey {
        case id
        case elements
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        self.id = try container.decode(UUID.self, forKey: .id)
        
        var elements = try container.decode([MessagePluginSubElementDTOType].self, forKey: .elements)
        
        guard let title = elements.getElement(ofType: InactivityPopupTitleElementDTO.self) else {
            throw DecodingError.dataCorruptedError(forKey: .elements, in: container, debugDescription: "Missing title in inactivity popup.")
        }
        guard let body = elements.getElement(ofType: InactivityPopupTextElementDTO.self) else {
            throw DecodingError.dataCorruptedError(forKey: .elements, in: container, debugDescription: "Missing body text in inactivity popup.")
        }
        guard let callToAction = elements.getElement(ofType: InactivityPopupTextElementDTO.self) else {
            throw DecodingError.dataCorruptedError(forKey: .elements, in: container, debugDescription: "Missing body text in inactivity popup.")
        }
        guard let countdown = elements.getElement(ofType: InactivityPopupCountdownElementDTO.self) else {
            throw DecodingError.dataCorruptedError(forKey: .elements, in: container, debugDescription: "Missing countdown in inactivity popup.")
        }
        guard let firstButton = elements.getElement(ofType: InactivityPopupButtonElementDTO.self) else {
            throw DecodingError.dataCorruptedError(forKey: .elements, in: container, debugDescription: "Missing one of the buttons in inactivity popup.")
        }
        guard let secondButton = elements.getElement(ofType: InactivityPopupButtonElementDTO.self) else {
            throw DecodingError.dataCorruptedError(forKey: .elements, in: container, debugDescription: "Missing one of the buttons in inactivity popup.")
        }
        
        self.title = title
        self.body = body
        self.callToAction = callToAction
        self.countdown = countdown
        self.expireButton = firstButton.isSessionRefresh ? secondButton : firstButton
        self.refreshButton = firstButton.isSessionRefresh ? firstButton : secondButton
    }
}

// MARK: - Array+MessagePluginSubElementDTOType

private extension Array where Element == MessagePluginSubElementDTOType {

    /// Removes and returns the first element of the specified type from the array.
    ///
    /// This method searches for the first occurrence of a subelement matching the given type,
    /// removes it from the array, and returns it cast to the expected type.
    /// If no matching element is found, the method logs an error and returns `nil`.
    ///
    /// - Note: This method modifies the original array by removing the found element.
    ///
    /// - Parameter type: The type of subelement to search for and return.
    ///
    /// - Returns: The first matching element cast to the specified type, or `nil` if not found.
    mutating func getElement<T: Decodable>(ofType type: T.Type) -> T? {
        let index = self.firstIndex { element in
            switch element {
            case .title where T.self == InactivityPopupTitleElementDTO.self:
                return true
            case .text where T.self == InactivityPopupTextElementDTO.self:
                return true
            case .countdown where T.self == InactivityPopupCountdownElementDTO.self:
                return true
            case .button where T.self == InactivityPopupButtonElementDTO.self:
                return true
            default:
                LogManager.error("Unexpected element type found in inactivity popup: \(element)")
                
                return false
            }
        }
        
        guard let index else {
            LogManager.error("Element of type \(T.self) not found in inactivity popup.")
            
            return nil
        }
        
        switch remove(at: index) {
        case .title(let entity):
            return entity as? T
        case .text(let entity):
            return entity as? T
        case .button(let entity):
            return entity as? T
        case .countdown(let entity):
            return entity as? T
        }
    }
}
