//
//  File.swift
//  
//
//  Created by Tyler Hendrickson on 3/6/22.
//

import Foundation

/// The different types of elements that can be present in the content of a message.
enum ElementType: String {
    
    /// Basic text.
    case text = "TEXT"
    
    /// A button that the customer can press.
    case button = "BUTTON"
    
    /// A file that the customer can view.
    case file = "FILE"
    
    /// A title to display.
    case title = "TITLE"
    
    /// A custom plugin that is displayed.
    case custom = "CUSTOM"
}
