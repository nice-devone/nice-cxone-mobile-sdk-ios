import Foundation


/// The different types of errors that may be experienced.
public enum CXoneChatError: LocalizedError, Equatable {

    // MARK: Errors when calling any method

    /// An attempt was made to use a method without connecting first.
    ///
    /// Most of the methods in the SDK require a connection to CXone services.
    ///  - Source of problem: SDK used incorrectly.
    /// - Attention: Make sure you call ``ConnectionProvider/connect(environment:brandId:channelId:)``
    ///     or ``ConnectionProvider/connect(chatURL:socketURL:brandId:channelId:)`` method first.
    case notConnected

    /// The method being called is not supported with the current channel configuration.
    ///
    /// Some features are available only with multithread channel configuration.
    ///  - Source of problem: SDK used incorrectly.
    /// - Attention: The channel is configured as a single-thread and called method requires a feature of multi-thread configuration,
    ///     e.g.  ``ChatThreadsProvider/create()``.
    case unsupportedChannelConfig

    /// The conversion from object instance to data failed.
    ///
    /// SDK is converting an object, like `String`, to the `Data` and the conversion failed.
    /// - Source of problem: SDK issue
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

    /// The server experienced an internal error and was unable to perform the action.
    ///
    /// SDK failed to upload attachment(s).
    /// - Source of problem: Unstable connection/SDK issue
    /// - Attention: Check if channel environment works correctly
    ///     or gather any information about how the error was encountered and contact the CXoneChat SDK team.
    case serverError

    /// The server experienced an error during recovering a thread or server does not contain any existing chat thread.
    ///
    /// This error indicates that thread recovery failed, either because the thread does not exist or for some other server-specific cause.
    /// - Source of problem: Information error/DFO issue
    /// - Warning: The SDK throws this error even in case of empty thread list.
    /// - Attention: Can be ignored in case of empty thread list.
    ///     Otherwise, gather any information about how the error was encountered and contact the CXoneChat SDK team.
    case recoveringThreadFailed
    
    /// The parameter has not been set properly or it was unable to unwrap it as a required type.
    ///
    /// The SDK tried to unwrap an object but it was missing. Could be internal object or data from the server.
    /// - Source of problem: DFO issue/SDK issue
    /// - Attention: Gather any information about how the error was encountered and contact the CXoneChat SDK team.
    case missingParameter(String)
    
    /// The brand has configured pre-chat survey with contact custom fields which needs to be provided via ``ChatThreadsProvider/create(with:)`` method.
    ///
    /// - Source of problem: SDK used incorrectly
    /// - Attention: Fill-up custom fields available in the ``ChatThreadsProvider/preChatSurvey``
    ///     and pass them as a parameter in the ``ChatThreadsProvider/create(with:)`` method.
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
    /// ``ConnectionProvider/connect(environment:brandId:channelId:)``
    ///     or ``ConnectionProvider/connect(chatURL:socketURL:brandId:channelId:)`` may throw this error in case of incorrectly set socket enpoint object.
    /// - Source of problem: SDK used incorrectly/SDK issue
    /// - Attention: Check entered IDs and URLs. Otherwise, gather any information about how the error was encountered and contact the CXoneChat SDK team.
    case invalidRequest

    /// Thread is missing the timestamp of when the message was created.
    ///
    /// Every thread message contains timestamp to be able to identify latest message for loading previously created
    ///     and not yet loaded messages via ``MessagesProvider/loadMore(for:)`` method.
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


    // MARK: - Properties

    public var errorDescription: String? {
        switch self {
        case .notConnected:
            return "You are trying to call a method without connecting first. Make sure you call connect first."
        case .unsupportedChannelConfig:
            return "The method you are trying to call is not supported with your current channel configuration."
                + " For example, archiving a thread is only supported on a channel configured for multiple threads."
        case .invalidData:
            return "Data was in an unexpected format and could not be decoded."
        case .invalidThread:
            return "The provided thread ID did not match any known threads"
        case .noMoreMessages:
            return "There aren’t any other messages so additional messages could not be loaded."
        case .attachmentError:
            return "The provided attachment wasn't able to be sent."
        case .webSocketConnectionFailure:
            return "Something went wrong and the WebSocket refused to connect."
                + "If you are providing your own chatURL or socketURL, double check that these URLs are correct."
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
        case .missingParameter(let param):
            return "Parameter \"\(param)\" was in an unexpected format or missing."
        case .recoveringThreadFailed:
            return "Could not get any existing chat thread."
        case .missingPreChatCustomFields:
            return "Could not create a new thread; need to fill out some contact custom fields with pre-chat survey."
        case .noSuchFile(let url):
            return "No such file at \(url)"
        case .unknownCaseCustomFields:
            return "The server does not contain definition for provided case custom field/s. Custom field/s will be ignored."
        case .unknownCustomerCustomFields:
            return "The server does not contain definition for provided customer custom field/s. Custom field/s will be ignored."
        case .customerAssociationFailure:
            return "The SDK instance could not get customer identity possibly because it may not have been set."
        }
    }


    // MARK: - Methods

    public static func == (lhs: Self, rhs: Self) -> Bool {
        type(of: lhs) == type(of: rhs) && lhs.localizedDescription == rhs.localizedDescription
    }
}
