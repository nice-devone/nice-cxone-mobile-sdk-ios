//
//  File.swift
//  
//
//  Created by kjoe on 1/27/22.
//

import Foundation

/// The various options for how a channel is configured.
public struct ChannelConfiguration: Codable {
    
    /// Whether the channel is for a live chat instead of asynchronous communication.
    public let isLiveChat: Bool
    
    /// Settings for the channel.
    public let settings: Settings
    
    /// Whether OAuth authorization is enabled for the channel.
    public let isAuthorizationEnabled: Bool
}

public struct Settings: Codable {
    /// Whether the channel supports multiple threads for the same user.
    public let hasMultipleThreadsPerEndUser: Bool
    
    // Whether the channel supports proactive chat features.
    public let isProactiveChatEnabled: Bool
}
