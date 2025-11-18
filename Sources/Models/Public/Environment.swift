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

/// The environment used for CXone.
public enum Environment: String, CaseIterable, EnvironmentDetails, Codable {

    /// Environment for North America.
    case NA1

    /// Environment for Europe.
    case EU1

    /// Environment for Australia.
    case AU1

    /// Environment for Canada.
    case CA1

    /// Environment for the United Kingdom.
    case UK1

    /// Environment for Japan.
    case JP1

    // MARK: - Properties
    
    /// The location name of the environment.
    public var location: String {
        switch self {
        case .NA1:
           return "North America"
        case .EU1:
           return "Europe"
        case .AU1:
           return "Australia"
        case .CA1:
           return "Canada"
        case .UK1:
            return "United Kingdom"
        case .JP1:
            return "Japan"
        }
    }

    /// The chat URL for the environment.
    public var chatURL: String {
        switch self {
        case .NA1:
            return "https://channels-de-na1.niceincontact.com/chat"
        case .EU1:
            return "https://channels-de-eu1.niceincontact.com/chat"
        case .AU1:
            return "https://channels-de-au1.niceincontact.com/chat"
        case .CA1:
            return "https://channels-de-ca1.niceincontact.com/chat"
        case .UK1:
            return "https://channels-de-uk1.niceincontact.com/chat"
        case .JP1:
            return "https://channels-de-jp1.niceincontact.com/chat"
        }
    }
    
    /// The socket URL for the environment.
    public var socketURL: String {
        switch self {
        case .NA1:
            return "wss://chat-gateway-de-na1.niceincontact.com"
        case .EU1:
            return "wss://chat-gateway-de-eu1.niceincontact.com"
        case .AU1:
            return "wss://chat-gateway-de-au1.niceincontact.com"
        case .CA1:
            return "wss://chat-gateway-de-ca1.niceincontact.com"
        case .UK1:
            return "wss://chat-gateway-de-uk1.niceincontact.com"
        case .JP1:
            return "wss://chat-gateway-de-jp1.niceincontact.com"
        }
    }
    
    public var loggerURL: String {
        switch self {
        case .NA1:
            return "https://app-de-na1.niceincontact.com/logger-public"
        case .EU1:
            return "https://app-de-eu1.niceincontact.com/logger-public"
        case .AU1:
            return "https://app-de-au1.niceincontact.com/logger-public"
        case .CA1:
            return "https://app-de-ca1.niceincontact.com/logger-public"
        case .UK1:
            return "https://app-de-uk1.niceincontact.com/logger-public"
        case .JP1:
            return "https://app-de-jp1.niceincontact.com/logger-public"
        }
    }
}
