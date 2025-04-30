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

/// The provider for report related properties and methods.
public protocol AnalyticsProvider {
    
    /// The id for the visitor.
    var visitorId: UUID? { get }
    
    /// Reports to CXone that a some page/screen in the app has been viewed by the visitor.
    ///
    /// - Parameters:
    ///   - title: The title or description of the page that was viewed.
    ///   - url: A URL uniquely identifying the page.
    ///
    /// - Throws: ``CXoneChatError/missingVisitorId``
    /// if ``ConnectionProvider/prepare(environment:brandId:channelId:)`` or ``ConnectionProvider/prepare(chatURL:socketURL:brandId:channelId:)``
    /// method was not called before triggering analytics event.
    /// - Throws: ``EncodingError.invalidValue(_:_:)`` if the given value is invalid in the current context for this format.
    /// - Throws: ``CXoneChatError/channelConfigFailure`` if the URL cannot be parsed, most likely because
    ///     environment.chatURL is not a valid URL.
    /// - Throws: ``URLError.badServerResponse`` if the URL Loading system received bad data from the server.
    /// - Throws: `EncodingError.invalidValue` if a non-conforming floating-point value is encountered during encoding, and the encoding strategy is `.throw`.
    /// - Throws: ``NSError`` object that indicates why the request failed
    func viewPage(title: String, url: String) async throws

    /// CXone reporting that a visitor has left a certain page/screen in the application.
    ///
    /// - Parameters:
    ///   - title: The title or description of the page that was left.
    ///   - url: A URL uniquely identifying the page.
    ///
    /// - Throws: ``CXoneChatError/missingVisitorId``
    /// if ``ConnectionProvider/prepare(environment:brandId:channelId:)`` or ``ConnectionProvider/prepare(chatURL:socketURL:brandId:channelId:)``
    /// method was not called before triggering analytics event.
    /// - Throws: ``EncodingError.invalidValue(_:_:)`` if the given value is invalid in the current context for this format.
    /// - Throws: ``CXoneChatError/channelConfigFailure`` if the URL cannot be parsed, most likely because
    ///     environment.chatURL is not a valid URL.
    /// - Throws: ``URLError.badServerResponse`` if the URL Loading system received bad data from the server.
    /// - Throws: `EncodingError.invalidValue` if a non-conforming floating-point value is encountered during encoding, and the encoding strategy is `.throw`.
    /// - Throws: ``NSError`` object that indicates why the request failed
    func viewPageEnded(title: String, url: String) async throws
    
    /// Reports to CXone that the chat window/view has been opened by the visitor.
    ///
    /// - Throws: ``CXoneChatError/missingVisitorId``
    /// if ``ConnectionProvider/prepare(environment:brandId:channelId:)`` or ``ConnectionProvider/prepare(chatURL:socketURL:brandId:channelId:)``
    /// method was not called before triggering analytics event.
    /// - Throws: ``EncodingError.invalidValue(_:_:)`` if the given value is invalid in the current context for this format.
    /// - Throws: ``CXoneChatError/channelConfigFailure`` if the URL cannot be parsed, most likely because
    ///     environment.chatURL is not a valid URL.
    /// - Throws: ``URLError.badServerResponse`` if the URL Loading system received bad data from the server.
    /// - Throws: `EncodingError.invalidValue` if a non-conforming floating-point value is encountered during encoding, and the encoding strategy is `.throw`.
    /// - Throws: ``NSError`` object that indicates why the request failed
    func chatWindowOpen() async throws
    
    /// Reports to CXone that a conversion has occurred.
    ///
    /// - Parameters:
    ///   - type: The type of conversion. Can be any value.
    ///   - value: The value associated with the conversion (for example, unit amount). Can be any number.
    ///
    /// - Throws: ``CXoneChatError/missingVisitorId``
    /// if ``ConnectionProvider/prepare(environment:brandId:channelId:)`` or ``ConnectionProvider/prepare(chatURL:socketURL:brandId:channelId:)``
    /// method was not called before triggering analytics event.
    /// - Throws: ``EncodingError.invalidValue(_:_:)`` if the given value is invalid in the current context for this format.
    /// - Throws: ``CXoneChatError/channelConfigFailure`` if the URL cannot be parsed, most likely because
    ///     environment.chatURL is not a valid URL.
    /// - Throws: ``URLError.badServerResponse`` if the URL Loading system received bad data from the server.
    /// - Throws: `EncodingError.invalidValue` if a non-conforming floating-point value is encountered during encoding, and the encoding strategy is `.throw`.
    /// - Throws: ``NSError`` object that indicates why the request failed
    func conversion(type: String, value: Double) async throws

    /// Reports to CXone that a proactive action was displayed to the visitor.
    ///
    /// - Parameter data: The proactive action that was displayed.
    ///
    /// - Throws: ``CXoneChatError/missingVisitorId``
    /// if ``ConnectionProvider/prepare(environment:brandId:channelId:)`` or ``ConnectionProvider/prepare(chatURL:socketURL:brandId:channelId:)``
    /// method was not called before triggering analytics event.
    /// - Throws: ``EncodingError.invalidValue(_:_:)`` if the given value is invalid in the current context for this format.
    /// - Throws: ``CXoneChatError/channelConfigFailure`` if the URL cannot be parsed, most likely because
    ///     environment.chatURL is not a valid URL.
    /// - Throws: ``URLError.badServerResponse`` if the URL Loading system received bad data from the server.
    /// - Throws: `EncodingError.invalidValue` if a non-conforming floating-point value is encountered during encoding, and the encoding strategy is `.throw`.
    /// - Throws: ``NSError`` object that indicates why the request failed
    func proactiveActionDisplay(data: ProactiveActionDetails) async throws
    
    /// Reports to CXone that a proactive action was clicked or acted upon by the visitor.
    ///
    /// - Parameter data: The proactive action that was clicked.
    ///
    /// - Throws: ``CXoneChatError/missingVisitorId``
    ///     if ``ConnectionProvider/prepare(environment:brandId:channelId:)`` or ``ConnectionProvider/prepare(chatURL:socketURL:brandId:channelId:)``
    ///     method was not called before triggering analytics event.
    /// - Throws: ``EncodingError.invalidValue(_:_:)`` if the given value is invalid in the current context for this format.
    /// - Throws: ``CXoneChatError/channelConfigFailure`` if the URL cannot be parsed, most likely because
    ///     environment.chatURL is not a valid URL.
    /// - Throws: ``URLError.badServerResponse`` if the URL Loading system received bad data from the server.
    /// - Throws: `EncodingError.invalidValue` if a non-conforming floating-point value is encountered during encoding, and the encoding strategy is `.throw`.
    /// - Throws: ``NSError`` object that indicates why the request failed
    func proactiveActionClick(data: ProactiveActionDetails) async throws
    
    /// Reports to CXone that a proactive action was successful or fails and lead to a conversion.
    ///
    /// - Parameter data: The proactive action that was successful or fails.
    /// - Throws: ``CXoneChatError/missingVisitorId``
    ///     if ``ConnectionProvider/prepare(environment:brandId:channelId:)`` or ``ConnectionProvider/prepare(chatURL:socketURL:brandId:channelId:)``
    ///     method was not called before triggering analytics event.
    /// - Throws: ``EncodingError.invalidValue(_:_:)`` if the given value is invalid in the current context for this format.
    /// - Throws: ``CXoneChatError/channelConfigFailure`` if the URL cannot be parsed, most likely because
    ///     environment.chatURL is not a valid URL.
    /// - Throws: ``URLError.badServerResponse`` if the URL Loading system received bad data from the server.
    /// - Throws: `EncodingError.invalidValue` if a non-conforming floating-point value is encountered during encoding, and the encoding strategy is `.throw`.
    /// - Throws: ``NSError`` object that indicates why the request failed
    func proactiveActionSuccess(_ isSuccess: Bool, data: ProactiveActionDetails) async throws
}
