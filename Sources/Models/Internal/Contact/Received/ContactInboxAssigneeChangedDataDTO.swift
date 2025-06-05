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

/// Data for the ContactInboxAssigneeChanged event.
struct ContactInboxAssigneeChangedDataDTO: Decodable, Equatable {

    /// The contact for which this change applies.
    let `case`: ContactDTO

    /// The agent that is now assigned to this contact.
    let inboxAssignee: AgentDTO?

    /// The agent that was previously assigned to the contact, if any.
    let previousInboxAssignee: AgentDTO?
}
