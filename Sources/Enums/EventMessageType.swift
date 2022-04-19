//
//  File.swift
//  
//
//  Created by Tyler Hendrickson on 3/6/22.
//

import Foundation

/// The different types of messages that can be sent to the WebSocket.
enum EventMessageType: String { // TODO: Rename this once other enum is changed
    
    /// The message is only sending text.
    case text = "TEXT"
    
    /// The message is sending a custom plugin to be displayed.
    case plugin = "PLUGIN"
}
