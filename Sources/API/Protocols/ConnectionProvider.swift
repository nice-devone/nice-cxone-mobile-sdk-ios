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

/// The provider for connection related properties and methods.
public protocol ConnectionProvider {
    
    /// The current channel configuration for currently connected CXone session.
    var channelConfiguration: ChannelConfiguration { get }
    
    /// Makes an HTTP request to get the channel configuration details.
    ///
    /// - Parameters:
    ///   - environment: The CXone ``Environment`` used to connect. Relates to your location.
    ///   - brandId: The unique id of the brand for which to open the connection.
    ///   - channelId: The unique id of the channel for the connection.
    ///
    /// - Throws: ``CXoneChatError/channelConfigFailure`` if provided parameters do not create a valid URL.
    /// - Throws: ``DecodingError.dataCorrupted`` an indication that the data is corrupted or otherwise invalid.
    /// - Throws: ``DecodingError.typeMismatch`` if the encountered stored value is not a JSON object or otherwise cannot be converted to the required type.
    /// - Throws: ``DecodingError.keyNotFound`` if the response does not have an entry for the given key.
    /// - Throws: ``DecodingError.valueNotFound`` if a response has a null value for the given key.
    /// - Throws: ``URLError.badServerResponse`` if the URL Loading system received bad data from the server.
    /// - Throws: ``NSError`` object that indicates why the request failed
    ///
    /// - Returns: Channel configuration details
    func getChannelConfiguration(environment: Environment, brandId: Int, channelId: String) async throws -> ChannelConfiguration
    
    /// Makes an HTTP request to get the channel configuration details.
    ///
    /// - Parameters:
    ///   - chatURL: The chat URL for the custom environment.
    ///   - brandId: The unique id of the brand for which to open the connection.
    ///   - channelId: The unique id of the channel for the connection.
    ///   - completion: Completion handler to be called when the request is successful or fails.
    ///
    /// - Throws: ``CXoneChatError/channelConfigFailure`` if provided parameters do not create a valid URL.
    /// - Throws: ``DecodingError.dataCorrupted`` an indication that the data is corrupted or otherwise invalid.
    /// - Throws: ``DecodingError.typeMismatch`` if the encountered stored value is not a JSON object or otherwise cannot be converted to the required type.
    /// - Throws: ``DecodingError.keyNotFound`` if the response does not have an entry for the given key.
    /// - Throws: ``DecodingError.valueNotFound`` if a response has a null value for the given key.
    /// - Throws: ``URLError.badServerResponse`` if the URL Loading system received bad data from the server.
    /// - Throws: ``NSError`` object that indicates why the request failed
    ///
    /// - Returns: Channel configuration details
    func getChannelConfiguration(chatURL: String, brandId: Int, channelId: String) async throws -> ChannelConfiguration
    
    /// Prepares the SDK for establishing connection to the CXone service.
    ///
    /// In order to use any ``AnalyticsProvider`` methods, you must first call this method.
    ///
    /// - Parameters:
    ///   - environment: The CXone ``Environment`` used to connect. Relates to your location.
    ///   - brandId: The unique id of the brand for which to open the connection.
    ///   - channelId: The unique id of the channel for the connection.
    ///
    /// - Throws: ``CXoneChatError/illegalChatState`` if it was unable to trigger the required method because the SDK is not in the required state
    /// - Throws: ``CXoneChatError/missingParameter(_:)`` if connection`url` is not in correct format.
    /// - Throws: ``CXoneChatError/channelConfigFailure`` if the SDK could not prepare URL for URLRequest
    /// - Throws: ``DecodingError.dataCorrupted`` an indication that the data is corrupted or otherwise invalid.
    /// - Throws: ``DecodingError.typeMismatch`` if the encountered stored value is not a JSON object or otherwise cannot be converted to the required type.
    /// - Throws: ``DecodingError.keyNotFound`` if the response does not have an entry for the given key.
    /// - Throws: ``DecodingError.valueNotFound`` if a response has a null value for the given key.
    /// - Throws: ``URLError.badServerResponse`` if the URL Loading system received bad data from the server.
    /// - Throws: ``NSError`` object that indicates why the request failed
    /// - Throws: `EncodingError.invalidValue` if a non-conforming floating-point value is encountered during encoding, and the encoding strategy is `.throw`.
    /// - Throws: An error if any value throws an error during encoding.
    func prepare(environment: Environment, brandId: Int, channelId: String) async throws
    
    /// Prepares the SDK for establishing connection to the CXone service.
    ///
    /// In order to you use any ``AnalyticsProvider`` methods, it is necessary to call this method before invoking any of them.
    ///
    /// - Parameters:
    ///   - chatURL: The URL to be used for chat requests (channel config and attachment upload).
    ///   - socketURL: The URL to be used for the WebSocket connection.
    ///   - brandId: The unique id of the brand for which to open the connection.
    ///   - channelId: The unique id of the channel for the connection.
    ///
    /// - Throws: ``CXoneChatError/illegalChatState`` if it was unable to trigger the required method because the SDK is not in the required state
    /// - Throws: ``CXoneChatError/missingParameter(_:)`` if connection`url` is not in correct format.
    /// - Throws: ``CXoneChatError/channelConfigFailure`` if the SDK could not prepare URL for URLRequest
    /// - Throws: ``DecodingError.dataCorrupted`` an indication that the data is corrupted or otherwise invalid.
    /// - Throws: ``DecodingError.typeMismatch`` if the encountered stored value is not a JSON object or otherwise cannot be converted to the required type.
    /// - Throws: ``DecodingError.keyNotFound`` if the response does not have an entry for the given key.
    /// - Throws: ``DecodingError.valueNotFound`` if a response has a null value for the given key.
    /// - Throws: ``URLError.badServerResponse`` if the URL Loading system received bad data from the server.
    /// - Throws: ``NSError`` object that indicates why the request failed
    /// - Throws: `EncodingError.invalidValue` if a non-conforming floating-point value is encountered during encoding, and the encoding strategy is `.throw`.
    /// - Throws: An error if any value throws an error during encoding.
    func prepare(chatURL: String, socketURL: String, brandId: Int, channelId: String) async throws

    /// Connects to the CXone service via web socket.
    ///
    /// This method establishes web socket connection to be able to receive chat events defined in ``CXoneChatDelegate``.
    ///
    /// - Precondition: Either ``prepare(environment:brandId:channelId:)`` or ``prepare(chatURL:socketURL:brandId:channelId:)`` method
    /// must be called before this method.
    ///
    /// - Throws: ``CXoneChatError/illegalChatState`` if it was unable to trigger the required method because the SDK is not in the required state
    /// - Throws: ``CXoneChatError/customerAssociationFailure`` if the SDK could not get customer identity and it may not have been set.
    /// - Throws: ``CXoneChatError/missingAccessToken`` if the customer was successfully authorized, but an access token wasn't returned.
    /// - Throws: ``CXoneChatError/invalidData`` when the Data object cannot be successfully converted to a valid UTF-8 string
    /// - Throws: ``CXoneChatError/invalidParameter(_:)`` if the socket endpoint URL has not been set properly
    /// - Throws: ``CXoneChatError/channelConfigFailure`` if the SDK could not prepare URL for URLRequest
    /// - Throws: ``EncodingError.invalidValue(_:_:)`` if the given value is invalid in the current context for this format.
    /// - Throws: ``URLError.badServerResponse`` if the URL Loading system received bad data from the server.
    /// - Throws: ``NSError`` object that indicates why the request failed
    func connect() async throws
    
    /// Disconnects from the CXone service and keeps the customer signed in.
    func disconnect()
    
    /// Pings the CXone chat server to ensure that a connection is established.
    ///
    /// - Throws: ``CXoneChatError/illegalChatState`` if it was unable to trigger the required method because the SDK is not in the required state
    @available(*, deprecated, message: "Deprecated as of 2.2.0")
    func ping() throws
    
    /// Manually executes a trigger that was defined in CXone. This can be used to test that proactive actions are displaying.
    ///
    /// - Parameter triggerId: The id of the trigger to manually execute.
    /// 
    /// - Throws: ``CXoneChatError/illegalChatState`` if it was unable to trigger the required method because the SDK is not in the required state
    /// - Throws: ``CXoneChatError/notConnected`` if an attempt was made to use a method without connecting first.
    ///     Make sure you call the `connect` method first.
    /// - Throws: ``CXoneChatError/customerVisitorAssociationFailure`` if the customer could not be associated with a visitor.
    /// - Throws: ``CXoneChatError/customerAssociationFailure`` The SDK instance could not get customer identity possibly because it may not have been set.
    /// - Throws: ``CXoneChatError/invalidData`` when the Data object cannot be successfully converted to a valid UTF-8 string
    /// - Throws: ``EncodingError.invalidValue(_:_:)`` if the given value is invalid in the current context for this format.
    /// - Throws: An error if any value throws an error during encoding.
    func executeTrigger(_ triggerId: UUID) throws
}
