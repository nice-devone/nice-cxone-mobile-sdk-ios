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

/// Response from the transaction token endpoint.
struct TransactionTokenDTO: Equatable, Expirable {

    // MARK: - Properties

    /// The token value used for WebSocket authentication.
    let value: String

    /// The number of seconds before the transaction token expires. Typically around 600 seconds (10 minutes).
    let expiresIn: Int

    /// The timestamp when this transaction token was created.
    ///
    /// - Note: If not provided by the backend, this value defaults to the current time during decoding.
    let createdDate: Date
    
    /// Customer identity information, if present.
    ///
    /// - Note: This property is currently unused internally, but is included for future use and for SDK consumers who may need customer identity information.
    let customerIdentity: CustomerIdentityDTO?
    
    /// The 3rd party OAuth access token for WebSocket communication (eg. `SendMessage`). Only present in OAuth flow.
    let accessToken: AccessTokenDTO?
}

// MARK: - Codable

extension TransactionTokenDTO: Codable {

    enum CodingKeys: String, CodingKey {
        case transactionToken = "accessToken"
        case expiresIn
        case customerIdentity
        case thirdParty
        case createdDate
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        self.value = try container.decode(String.self, forKey: .transactionToken)
        self.expiresIn = try container.decode(Int.self, forKey: .expiresIn)
        self.customerIdentity = try container.decodeIfPresent(CustomerIdentityDTO.self, forKey: .customerIdentity)
        self.createdDate = try container.decodeIfPresent(Date.self, forKey: .createdDate) ?? .now
        self.accessToken = try container.decodeIfPresent(AccessTokenDTO.self, forKey: .thirdParty)
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        
        try container.encode(value, forKey: .transactionToken)
        try container.encode(expiresIn, forKey: .expiresIn)
        try container.encode(customerIdentity, forKey: .customerIdentity)
        try container.encode(createdDate, forKey: .createdDate)
        
        if let accessToken {
            try container.encode(accessToken, forKey: .thirdParty)
        }
    }
}

// MARK: - Methods

extension TransactionTokenDTO {
    
    func copy(accessToken: AccessTokenDTO) -> TransactionTokenDTO {
        TransactionTokenDTO(
            value: self.value,
            expiresIn: self.expiresIn,
            createdDate: self.createdDate,
            customerIdentity: self.customerIdentity,
            accessToken: accessToken
        )
    }
}
