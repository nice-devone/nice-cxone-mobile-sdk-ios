//
//  File.swift
//  
//
//  Created by kjoe on 1/18/22.
//

import Foundation
struct ServerError {
    let message: String
    let connectionId: String
    let requestId: String
}

extension ServerError: Codable {}

extension ServerError: Error {}

extension ServerError: LocalizedError {
    var errorDescription: String? {
        return message
    }
}


struct ErrorResponse: Codable {
    let eventId: String
    let error: ServerError
}
