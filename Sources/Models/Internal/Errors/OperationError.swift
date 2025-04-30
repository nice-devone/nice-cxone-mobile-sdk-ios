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

struct OperationError: LocalizedError {

    // MARK: - Properties

    let eventId: UUID
    
    let errorCode: ErrorCode

    let transactionId: LowerCaseUUID

    let errorMessage: String

    var errorDescription: String? {
        """
        {
            "eventType": "\(errorCode.rawValue)"
            "transactionId": "\(transactionId.uuid.uuidString)"
            "errorMessage" "\(errorMessage)"
        }
        """
    }
}

// MARK: - Equatable

extension OperationError: Equatable {
    
    static func == (lhs: OperationError, rhs: OperationError) -> Bool {
        lhs.errorCode == rhs.errorCode
            && lhs.transactionId == rhs.transactionId
            && lhs.errorMessage == rhs.errorMessage
    }
}

// MARK: - ReceivedEvent

extension OperationError: ReceivedEvent {
    static let eventType: EventType? = nil

    var postbackEventType: EventType? { nil }
    var postbackErrorCode: ErrorCode? { errorCode }
    var eventType: EventType? { nil }
}

// MARK: - Codable

extension OperationError: Codable {
    
    enum CodingKeys: CodingKey {
        case eventId
        case error
    }
    
    enum ErrorKeys: CodingKey {
        case errorCode
        case transactionId
        case errorMessage
    }
    
    init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.eventId = try container.decodeUUIDIfPresent(forKey: .eventId) ?? UUID.provide()
        
        let errorContainer = try container.nestedContainer(keyedBy: ErrorKeys.self, forKey: .error)
        self.errorCode = try errorContainer.decode(ErrorCode.self, forKey: .errorCode)
        self.transactionId = try errorContainer.decode(LowerCaseUUID.self, forKey: .transactionId)
        self.errorMessage = try errorContainer.decode(String.self, forKey: .errorMessage)
    }
    
    func encode(to encoder: any Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(self.eventId, forKey: .eventId)
        
        var errorContainer = container.nestedContainer(keyedBy: ErrorKeys.self, forKey: .error)
        try errorContainer.encode(self.errorCode, forKey: .errorCode)
        try errorContainer.encode(self.transactionId, forKey: .transactionId)
        try errorContainer.encode(self.errorMessage, forKey: .errorMessage)
    }
}
