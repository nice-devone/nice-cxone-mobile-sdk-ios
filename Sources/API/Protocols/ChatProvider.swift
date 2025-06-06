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

import CXoneGuideUtility
import Foundation

/// The interface for interacting with chat features of the CXone platform.
public protocol ChatProvider: AnyObject {
    
    /// The singleton instance of the CXone chat SDK.
    static var shared: ChatProvider { get set }
    
    /// The handler for the logs occured in CXone chat.
    static var logWriter: LogWriter? { get set }

    /// Current chat state of the SDK
    ///
    /// The state defines whether it is necessary to set up the SDK, connect to the CXone services or start communication with an agent.
    var state: ChatState { get }
    
    /// Chat mode based on the channel configuration
    var mode: ChatMode { get }
    
    /// The provider for connection related properties and methods.
    var connection: ConnectionProvider { get }
    
    /// The provider for customer related properties and methods.
    var customer: CustomerProvider { get }
    
    /// The provider for customer chat fields related properties and methods.
    var customerCustomFields: CustomerCustomFieldsProvider { get }
    
    /// The provider for thread related properties and methods.
    var threads: ChatThreadListProvider { get }
    
    /// The provider for report related properties and methods.
    var analytics: AnalyticsProvider { get }
    
    /// Add a ``CXoneChatDelegate``
    ///
    /// Future delegate messages will be routed to the newly added delegate.
    ///
    /// Note: No strong reference to the delegate is maintained so the caller
    /// is responsible for its lifecycle.
    func add(delegate: CXoneChatDelegate)

    /// Remove a `CXoneChatDelegate``
    ///
    /// No future delegate messages will be routed to the removed delegate.
    func remove(delegate: CXoneChatDelegate)

    /// Signs the customer out and disconnects from the CXone service.
    static func signOut()
}
