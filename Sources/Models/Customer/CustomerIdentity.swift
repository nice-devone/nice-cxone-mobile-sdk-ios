//
//  File.swift
//  
//
//  Created by Tyler Hendrickson on 3/6/22.
//

import Foundation

/// Represents information about a customer identity to be sent on events.
public struct CustomerIdentity: Codable {
    /// The unique id for the customer identity.
    let idOnExternalPlatform: String
    
    /// The first name of the customer. Use when sending a message to set the name in MAX.
    var firstName: String? = nil
    
    /// The first name of the customer. Use when sending a message to set the name in MAX.
    var lastName: String? = nil

}
