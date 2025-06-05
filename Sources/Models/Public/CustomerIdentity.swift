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

/// Represents information about a customer identity to be sent on events.
public struct CustomerIdentity: Equatable {
    
    // MARK: - Properties
    
    private static let personNameComponentsFormatter = PersonNameComponentsFormatter()
    
    /// The unique id for the customer identity.
    public let id: String
    
    /// The first name of the customer. Use when sending a message to set the name in MAX.
    public var firstName: String?
    
    /// The last name of the customer. Use when sending a message to set the name in MAX.
    public var lastName: String?
    
    /// The full name of the customer.
    public var fullName: String? {
        var nameComponents = PersonNameComponents()
        nameComponents.givenName = firstName
        nameComponents.familyName = lastName
        
        return Self.personNameComponentsFormatter.string(from: nameComponents)
    }
    
    // MARK: - Init
    
    /// - Parameters:
    ///   - id: The unique id for the customer identity.
    ///   - firstName: The first name of the customer. Use when sending a message to set the name in MAX.
    ///   - lastName: The last name of the customer. Use when sending a message to set the name in MAX.
    public init(id: String, firstName: String?, lastName: String?) {
        self.id = id
        self.firstName = firstName
        self.lastName = lastName
    }
}
