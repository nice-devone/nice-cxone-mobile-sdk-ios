//
//  File.swift
//  
//
//  Created by Tyler Hendrickson on 3/6/22.
//

import Foundation

/// The different types of actions for an event.
enum EventAction: String {
    
    /// The customer is registering for chat access.
    case register = "register"
    
    /// The customer is interacting with something in the chat window.
    case chatWindowEvent = "chatWindowEvent"
    
    /// The customer is making an outbound action.
    case outbound = "outbound"
}
