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

/// State of the chat
///
/// Here is a table of states with their basic description. Those states are internally handled by the SDK based on its usage.
/// 
/// | State                         | Description
/// | --------------------------  | -------------------------------------------------------------------------------------------------------
/// | ``initial``         | Initial state of the SDK
/// | ``preparing``     | The SDK is preparing for usage
/// | ``prepared``       | The SDK has been prepared for basic usage = unable to use chat features!.
/// | ``offline``         | Channel currently unavailable (only for live chat channel configuration).
/// | ``connecting``  | Socket connection is establishing for chat usage
/// | ``connected``    | Socket connection has been established
/// | ``ready``             | Chat is ready to use based on it's configuration status
/// | ``closed``           | An agent or customer has closed the thread
public enum ChatState: Comparable {
    
    // MARK: - Cases
    
    /// Initial state of the SDK
    ///
    /// The SDK has not yet been prepared for usage
    case initial
    
    /// The SDK is preparing for usage
    ///
    /// Websocket connection is not being established but it is possible to use ``AnalyticsProvider``
    case preparing
    
    /// The SDK has been prepared for basic usage (unable to use chat features).
    ///
    /// Channel configuration has been received and it is possible to use ``AnalyticsProvider``.
    /// For chat usage it is necessary to CXone services via ``ConnectionProvider/connect()``
    case prepared
    
    /// Channel currently unavailable
    ///
    /// Each live chat channel has a defined availability when it is possible to connect to an agent.
    /// This state defines a situation where the channel is currently unavailable and will need to be connected later.
    ///
    /// - Precondition: ``CXoneChat.status == .liveChat``
    case offline
    
    /// Socket connection is establishing for chat usage
    case connecting
    
    /// Socket connection has been established
    case connected
    
    /// Chat is ready to use based on it's configuration status
    ///
    /// ## Singlethread
    /// After the connection is established, the SDK automatically recovers any previously created thread.
    /// If there is no thread to recover, it automatically creates a new one.
    ///
    /// ## Multithread
    /// After establishing a connection, the SDK automatically fetches the thread list and loads metadata for each thread.
    /// If there are no threads, the state is set to `.ready` and empty chat list screen should be presented.
    ///
    /// ## LiveChat
    /// Not yet implemented. Available from version 1.4.0
    case ready
    
    /// An agent or customer has closed the thread
    ///
    /// Whenever a thread is closed, the application should disable the sending of further messages
    /// and display the End Contact Experience screen.
    ///
    /// - Precondition: ``CXoneChat.status == .liveChat``
    case closed
    
    // MARK: - Properties
    
    /// Check if chat is currently connected to the Websocket
    ///
    /// - Attention: State is either ``connected``, ``ready`` or ``closed``.
    public var isChatAvailable: Bool {
        [.connected, .ready, .closed].contains(self)
    }
    
    /// Check if chat is currently prepared and ready for establish connection or analytics use.
    ///
    /// - Attention: State is either ``prepared``, ``offline``, ``connecting``, ``connected``, ``ready`` or ``closed``.
    public var isAnalyticsAvailable: Bool {
        ![.initial, .preparing].contains(self)
    }
    
    /// Check if chat is able to be prepared.
    ///
    /// ``ConnectionProvider/prepare(environment:brandId:channelId:)`` should not be called when the chat is available (``isChatAvailable`` is `true`).
    /// - Attention: State is either ``initial``, ``prepared`` or ``offline``-
    public var isPrepareable: Bool {
        [.initial, .prepared, .offline].contains(self)
    }
}
