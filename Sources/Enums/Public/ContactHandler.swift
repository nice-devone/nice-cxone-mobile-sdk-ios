//
// Copyright (c) 2021-2026. NICE Ltd. All rights reserved.
//
// Licensed under the NICE License;
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//    https://github.com/nice-devone/nice-cxone-mobile-sdk-ios/blob/main/LICENSE
//
// TO THE EXTENT PERMITTED BY APPLICABLE LAW, THE CXONE MOBILE SDK IS PROVIDED ON
// AN "AS IS" BASIS. NICE HEREBY DISCLAIMS ALL WARRANTIES AND CONDITIONS, EXPRESS
// OR IMPLIED, INCLUDING (WITHOUT LIMITATION) WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE, NON-INFRINGEMENT, AND TITLE.
//

import Foundation

/// The party currently responsible for handling a contact.
///
/// A contact starts out held by whichever party the channel is configured to engage first. While an automated bot
/// holds it, the customer is not queued for a human agent - there is no position in queue to report. Once the bot
/// hands the conversation over, the handler becomes ``cxone`` and the regular routing rules apply again.
///
/// The platform only reports a handler on channels where the capability is enabled, which is why
/// ``ChatThread/contactHandler`` is optional.
public enum ContactHandler: String, Equatable, Sendable {

    /// The contact is handled by CXone routing - it is queued for, or assigned to, a human agent.
    case cxone

    /// The contact is handled by the Cognigy bot.
    case cognigy

    /// The contact is handled by a party this version of the SDK does not recognize.
    ///
    /// Treat it as *not* ``cxone`` - the contact is being served by something other than CXone routing.
    case unknown
}
