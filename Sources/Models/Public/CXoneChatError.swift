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

/// The different types of errors that may be experienced.
public enum CXoneChatError: LocalizedError, Equatable {

    // MARK: Errors when calling any method

    /// An attempt was made to use a method without connecting first.
    ///
    /// Most of the methods in the SDK require a connection to CXone services.
    ///  - Source of problem: SDK used incorrectly.
    /// - Attention: Make sure you call ``ConnectionProvider/connect()``
    ///     or ``ConnectionProvider/connect()`` method first.
    case notConnected

    /// The method being called is not supported with the current channel configuration.
    ///
    /// Some features are available only with multithread channel configuration.
    ///  - Source of problem: SDK used incorrectly.
    /// - Attention: The channel is configured as a single-thread and called method requires a feature of multi-thread configuration,
    ///     e.g.  ``ChatThreadListProvider/create()``.
    case unsupportedChannelConfig

    /// The conversion from object instance to data failed or when the Data object cannot be successfully converted to a valid UTF-8 string
    ///
    /// SDK is converting an object, like `String`, to the `Data` and vice versa and the conversion failed.
    /// - Source of problem: SDK/DFO issue
    /// - Attention: Gather any information about how the error was encountered and contact the CXoneChat SDK team.
    case invalidData

    /// The provided ID for the thread was invalid, so the action could not be performed.
    ///
    /// The SDK tried to find required thread but it does not exist or it is no more available.
    /// - Source of problem: SDK used incorrectly
    /// - Attention: Check if thread exists and you are providing correct thread `id` which reffers to `threadIdOnExternalPlatform`.
    case invalidThread

    /// There aren't any other messages, so additional messages could not be loaded.
    /// - Attention: Gather any information about how the error was encountered and contact the CXoneChat SDK team.
    case noMoreMessages

    /// The provided attachment was unable to be sent.
    ///
    /// CXone service does not receive any/all attachments.
    /// - Source of problem: Unstable connection/SDK issue
    /// - Attention: Check if channel environment works correctly
    ///     or gather any information about how the error was encountered and contact the CXoneChat SDK team.
    case attachmentError
    
    /// The size of the attachment exceeds the allowed size
    ///
    /// Channel ``ChannelConfiguration/fileRestrictions`` define allowed file size which can be received by the backend
    /// - Source of problem: SDK used incorrectly
    /// - Attention: Attachments should be validated for correct file size by the host application
    case invalidFileSize
    
    /// The type of the attachment is not included in the allowed file MIME type
    ///
    /// Channel ``ChannelConfiguration/fileRestrictions`` define allowed file MIME types which can be received by the backned
    /// - Source of problem: SDK used incorrectly
    /// - Attention: Attachments should be validated for correct file type by the host application
    case invalidFileType

    /// The server experienced an internal error and was unable to perform the action.
    ///
    /// SDK failed to upload attachment(s).
    /// - Source of problem: Unstable connection/SDK issue
    /// - Attention: Check if channel environment works correctly
    ///     or gather any information about how the error was encountered and contact the CXoneChat SDK team.
    case serverError

    /// The server experienced an error during recovering a messaging thread or server does not contain any existing chat thread.
    ///
    /// This error indicates that thread recovery failed, either because the thread does not exist or for some other server-specific cause.
    /// - Source of problem: Information error/DFO issue
    /// - Warning: The SDK throws this error even in case of empty thread list.
    /// - Attention: Can be ignored in case of empty thread list.
    ///     Otherwise, gather any information about how the error was encountered and contact the CXoneChat SDK team.
    @available(*, deprecated, message: "Error is no longer forwarded to the host application – it is handled internally from version 1.3.0")
    case recoveringThreadFailed
    
    /// The parameter has not been set properly or it was unable to unwrap it as a required type.
    ///
    /// The SDK tried to unwrap an object but it was missing. Could be internal object or data from the server.
    /// - Source of problem: DFO issue/SDK issue
    /// - Attention: Gather any information about how the error was encountered and contact the CXoneChat SDK team.
    case missingParameter(String)

    /// A invalid parameter has been passed to a method call.
    ///
    /// This is one of:
    /// - ``ChatThreadProvider.send(_:)`` was called with no valid postback, empty text, and no attachments.
    case invalidParameter(String)

    /// The brand has configured pre-chat survey with contact custom fields which needs to be provided via ``ChatThreadListProvider/create(with:)`` method.
    ///
    /// - Source of problem: SDK used incorrectly
    /// - Attention: Fill-up custom fields available in the ``ChatThreadListProvider/preChatSurvey``
    ///     and pass them as a parameter in the ``ChatThreadListProvider/create(with:)`` method.
    case missingPreChatCustomFields

    /// A provided custom field does not have a definition in the case custom fields.
    ///
    /// CXone service handles only those custom fields that are configured in the brand settings and others are ignored.
    /// - Source of problem: SDK used incorrectly
    /// - Attention: Check content of the ``ConnectionProvider/channelConfiguration``,
    ///     specifically ``ChannelConfiguration/contactCustomFieldDefinitions`` or your brand settings.
    case unknownCaseCustomFields
    
    /// A provided custom field does not have a definition in the customer custom fields.
    ///
    /// CXone service handles only those custom fields that are configured in the brand settings and others are ignored.
    /// - Source of problem: SDK used incorrectly
    /// - Attention: Check content of the ``ConnectionProvider/channelConfiguration``,
    ///     specifically ``ChannelConfiguration/customerCustomFieldDefinitions`` or your brand settings.
    case unknownCustomerCustomFields

    /// The SDK instance could not get customer identity possibly because it may not have been set.
    ///
    /// Customer identity is necessary for binding threads to the visitor.
    /// - Source of problem: SDK used incorrectly/SDK issue
    /// - Attention: Gather any information about how the error was encountered and contact the CXoneChat SDK team.
    case customerAssociationFailure
    
    // MARK: Errors when calling connect

    /// The WebSocket refused to connect.
    ///
    /// This error may occur within connection establishing process
    ///     and it can relate to several issues - wrong IDs, an internet or CXone service connectivity issue or wrong connection URL.
    /// - Source of problem: SDK used incorrectly/DFO issue
    /// - Attention: Check entered BrandID and ChannelID. If you are providing your own chatURL or socketURL, double check that these URLs are correct.
    ///     Otherwise, Gather any information about how the error was encountered and contact the CXoneChat SDK team.
    case webSocketConnectionFailure
    
    /// The channel configuration could not be retrieved.
    ///
    /// This error may occur with getting channel configuration and it can relate to several issues - wrong IDs or wrong connection URL.
    /// - Source of problem: SDK used incorrectly
    /// - Attention: Check entered BrandID and ChannelID. If you are providing your own chatURL or socketURL, double check that these URLs are correct.
    case channelConfigFailure

    /// The customer was successfully authorized, but an access token wasn't returned.
    ///
    /// The access token is used in case of OAuth authorization process.
    /// - Source of problem: DFO issue
    /// - Attention: Gather any information about how the error was encountered and contact the CXoneChat SDK team.
    case missingAccessToken

    /// The customer could not be associated with a visitor.
    ///
    /// Some events, except customer identity, uses `visitorId` to match an user.
    /// - Source of problem: SDK issue
    /// - Attention: Gather any information about how the error was encountered and contact the CXoneChat SDK team.
    case customerVisitorAssociationFailure

    /// The connection request was invalid and couldn't be completed.
    ///
    /// ``ConnectionProvider/connect()``
    ///     or ``ConnectionProvider/connect()`` may throw this error in case of incorrectly set socket enpoint object.
    /// - Source of problem: SDK used incorrectly/SDK issue
    /// - Attention: Check entered IDs and URLs. Otherwise, gather any information about how the error was encountered and contact the CXoneChat SDK team.
    case invalidRequest

    /// Thread is missing the timestamp of when the message was created.
    ///
    /// Every thread message contains timestamp to be able to identify latest message for loading previously created
    ///     and not yet loaded messages via ``ChatThreadProvider/loadMoreMessages`` method.
    /// - Source of problem: DFO issue
    /// - Attention: Gather any information about how the error was encountered and contact the CXoneChat SDK team.
    case invalidOldestDate

    /// An attached file could not be found.
    ///
    /// It has been stored in an unknown location or its location is not accessible from the secure scope and it is not handled.
    /// - Source of problem: SDK used incorrectly/SDK issue
    /// - Attention: Store your attachment in the secured scope or in the application documents directory.
    ///     Otherwise, gather any information about how the error was encountered and contact the CXoneChat SDK team.
    case noSuchFile(String)

    /// An analytics event has been generated when no visit was available.
    ///
    /// - Attention: ``AnalyticsProvider/viewPage(title:url:)`` must be called before any other analytics events are generated
    case missingVisitId

    /// ``ConnectionProvider/connect()`` or an analytics event has been generated when no visitor id was available.
    ///
    /// - Attention: ``ConnectionProvider/prepare(environment:brandId:channelId:)`` or
    /// ``ConnectionProvider/prepare(chatURL:socketURL:brandId:channelId:)``
    /// must be called before ``ConnectionProvider/connect()`` or any other analytics events are generated.
    case missingVisitorId

    /// Unable to trigger the required method because the SDK is not in the required state.
    ///
    /// The SDK has to be in correct state to trigger required operation. For example, connecting to the CXone service for chatting with an agent,
    /// it is firstly necessary to ``ConnectionProvider/prepare(environment:brandId:channelId:)`` channel configuration
    /// which leads to the ``ChatState/prepared`` state and then it's possible  to ``ConnectionProvider/connect()`` to the websocket.
    ///
    /// Check ``ChatState`` for more information.
    ///
    /// ## Source of problem
    /// SDK used incorrectly
    case illegalChatState
    
    /// Unable to trigger the required method because the chat thread is not in the required state.
    ///
    /// The chat thread has to be in correct state to trigger required operation. 
    /// For example, to update thread name via ``ChatThreadListProvider/updateName(_:for:)``
    /// the thread can not be in ``ChatThreadState/closed`` state.
    ///
    /// Check ``ChatThreadState`` for more information.
    ///
    /// ## Source of problem
    /// SDK used incorrectly
    case illegalThreadState
    
    /// Did not receive a paired response from the server in the expected time.
    ///
    /// The SDK sent a request event to the server, but the server did not respond in the expected time.
    ///
    /// - Source of problem: SDK issue, DFO issue
    /// - Attention: Gather any information about how the error was encountered and contact the CXoneChat SDK team.
    case eventTimeout
    
    // MARK: - Properties

    public var errorDescription: String? {
        switch self {
        case .notConnected:
            return "You are trying to call a method without connecting first. Make sure you call connect first."
        case .unsupportedChannelConfig:
            return "The method you are trying to call is not supported with your current channel configuration"
                + " For example, archiving a thread is only supported on a channel configured for multiple threads."
        case .invalidData:
            return "Data was in an unexpected format and could not be decoded."
        case .invalidThread:
            return "The provided thread ID did not match any known threads."
        case .noMoreMessages:
            return "There aren’t any other messages so additional messages could not be loaded."
        case .attachmentError:
            return "The provided attachment wasn't able to be sent."
        case .webSocketConnectionFailure:
            return "Something went wrong and the WebSocket refused to connect."
                + " If you are providing your own chatURL or socketURL, double check that these URLs are correct."
        case .channelConfigFailure:
            return "Something went wrong and the channel configuration could not be retrieved."
        case .missingAccessToken:
            return "The customer was successfully authorized using OAuth, but an access token wasn’t returned."
        case .customerVisitorAssociationFailure:
            return "The customer could not be successfully associated with a visitor."
        case .serverError:
            return "Internal server error."
        case .invalidRequest:
            return "Could not make the request because the URL was malformed."
        case .invalidOldestDate:
            return "No oldest message date is saved."
        case .invalidParameter(let param):
            return "Parameter is invalid: \(param)"
        case .missingParameter(let param):
            return "Parameter \"\(param)\" was in an unexpected format or missing."
        case .recoveringThreadFailed:
            return "Could not get any existing chat thread."
        case .missingPreChatCustomFields:
            return "Could not create a new thread; need to fill out some contact custom fields with pre-chat survey."
        case .noSuchFile(let url):
            return "No such file at \(url)."
        case .unknownCaseCustomFields:
            return "The server does not contain definition for provided case custom field(s). Custom field(s) will be ignored."
        case .unknownCustomerCustomFields:
            return "The server does not contain definition for provided customer custom field(s). Custom field(s) will be ignored."
        case .customerAssociationFailure:
            return "The SDK instance could not get customer identity possibly because it may not have been set."
        case .missingVisitId:
            return "An analytics event was generated before AnalyticsProvider.pageView(title:url:) was called."
        case .missingVisitorId:
            return "`connect()` or an analytics event has been generated when no visitor id was available."
        case .illegalChatState:
            return "Unable to trigger required method because chat is not in required state."
        case .invalidFileSize:
            return "The size of the attachment exceeds the allowed size."
        case .invalidFileType:
            return "The type of the attachment is not included in the allowed file MIME type."
        case .illegalThreadState:
            return "Unable to trigger required method because thread is not in required state."
        case .eventTimeout:
            return "Did not receive a paired response from the server in the expected time."
        }
    }

    // MARK: - Methods

    public static func == (lhs: Self, rhs: Self) -> Bool {
        type(of: lhs) == type(of: rhs) && lhs.localizedDescription == rhs.localizedDescription
    }
}
