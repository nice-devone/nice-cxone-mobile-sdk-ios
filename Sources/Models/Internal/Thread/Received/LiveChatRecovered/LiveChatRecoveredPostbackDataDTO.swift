//
// Copyright (c) 2021-2024. NICE Ltd. All rights reserved.
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

struct LiveChatRecoveredPostbackDataDTO: Decodable {
    
    /// The info about a contact (case).
    let contact: ContactDTO
    
    /// The info about an agent.
    let inboxAssignee: AgentDTO?
    
    /// The last agent that has been assigned to the thread
    let previousInboxAssignee: AgentDTO?
    
    /// The list of messages on the thread.
    let messages: [MessageDTO]
    
    let messagesScrollToken: String
    
    /// The info abount about received thread.
    let thread: ReceivedThreadDataDTO
}
