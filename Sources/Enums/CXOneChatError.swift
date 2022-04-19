//
//  File.swift
//  
//
//  Created by Tyler Hendrickson on 3/7/22.
//

import Foundation

/// The different types of errors that may be experienced.
public enum CXOneChatError: Error, LocalizedError {
    /// The configuration for the channel is not loaded and the operation could not be performed.
    case missingChannelConfig

    /// The case id was invalid and the operation is unable to be performed.
    case invalidCaseId
    
    /// The server experienced an internal error and was unable to perform the action.
    case serverError
    
    /// The conversion from object instance to data failed.
    case invalidData
    
    /// The request was invalid and couldn't be completed.
    case invalidRequest
    
    case socketNotReady
    
    case invalidBrandId
    case invalidChannelId
    case invalidCustomerId
    case invalidThread
    case missingcontactId
    case noMoreMessages
    
    case invalidMessageId
    
    case invalidOldestDate
    
    case invalidVisitor
    
    public var errorDescription: String? {
        switch self {
        case .missingChannelConfig:
            return "The configuration for the channel is not loaded and the operation could not be performed."
        case .invalidCaseId:
            return "Could not update customer contact field; need to send a message first to open channel"
        case .serverError:
            return "Internal server error"
        case .invalidData:
            return "Data could not be converted"
        case .invalidRequest:
            return "Could not make the request because the URL was malformed"
        case .socketNotReady:
            return "Socket not connected, please call connect before calling this funtion"        
        case .invalidBrandId:
            return "the brand id is not valid"
        case .invalidChannelId:
            return "the channel id is not valid"
        case .invalidCustomerId:
            return "the customer id is not valid"
        case .invalidThread:
            return "No active thread."
        case .missingcontactId:
            return "Missing contact id"
        case .noMoreMessages:
            return "this thread has no more message"
        case .invalidMessageId:
            return "message id is not valid"
        case .invalidOldestDate:
            return "no oldest message date is saved."
        case .invalidVisitor:
            return "Invalid visitor."
        }
    }
}
