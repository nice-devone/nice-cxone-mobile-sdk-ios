//
//  File.swift
//  
//
//  Created by kjoe on 2/18/22.
//

import Foundation

/// An access token used by the customer for sending messages if OAuth authorization is on for the channel.
public struct AccessToken {
    
    /// The actual token value.
    let token: String
    
    /// The number of seconds before the access token becomes invalid.
    private let expiresIn: Int

    /// The date at which this access token was created.
    private let currentDate: Date?
    
   
}

extension AccessToken: Codable {}

extension AccessToken {
    /// Whether the token has expired or not.
    var isExpired: Bool {
        guard let currentDate = currentDate else {return false}
        let date = Calendar.current.dateComponents([.second], from: currentDate, to: Date())
        return date.second ?? 0 > expiresIn
    }
}
