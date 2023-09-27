//
// Copyright (c) 2021-2023. NICE Ltd. All rights reserved.
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

// CustomerIdentityView

/// Represents information about a customer identity to be sent on events.
struct CustomerIdentityDTO: Codable {
    
    /// The unique id for the customer identity.
    let idOnExternalPlatform: String
    
    /// The first name of the customer. Use when sending a message to set the name in MAX.
    var firstName: String?
    
    /// The last name of the customer. Use when sending a message to set the name in MAX.
    var lastName: String?
}
