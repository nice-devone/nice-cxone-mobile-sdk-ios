import Foundation


/// The different types of errors that may be experienced.
enum CXoneChatError: LocalizedError, Equatable {

    // MARK: Errors when calling any method

    /// An attempt was made to use a method without connecting first. Make sure you call the `connect` method first.
    case notConnected

    /// The method being called is not supported with the current channel configuration.
    case unsupportedChannelConfig

    /// The conversion from object instance to data failed.
    case invalidData

    /// The provided ID for the thread was invalid, so the action could not be performed.
    case invalidThread

    /// There aren't any other messages, so additional messages could not be loaded.
    case noMoreMessages

    /// The provided attachment was unable to be sent.
    case attachmentError

    /// The case id was invalid and the operation is unable to be performed.
    case invalidCaseId

    /// The server experienced an internal error and was unable to perform the action.
    case serverError

    /// The parameter  has not been set properly.
    case missingParameter(String)


    // MARK: Errors when calling connect

    /// The WebSocket refused to connect.
    case webSocketConnectionFailure
    /// The channel configuration could not be retrieved.
    case channelConfigFailure
    /// The customer could not be authorized anonymously.
    case anonymousAuthorizationFailure

    /// The customer could not be authorized using the OAuth details configured on the channel.
    case oAuthAuthorizationFailure

    /// The auth code has not been set, but an attempt has been made to authorize.
    case missingAuthCode

    /// The returning customer could not be reconnected.
    case reconnectFailure

    /// The customer was successfully authorized, but an access token wasn't returned.
    case missingAccessToken

    /// The customer was successfully authorized, but a customerId wasn't returned.
    case missingCustomerId

    /// The customer could not be associated with a visitor.
    case customerVisitorAssociationFailure

    /// The request was invalid and couldn't be completed.
    case invalidRequest

    /// The unique id is of the customer currently using the app is missing.
    case invalidCustomerId

    /// The unique contact id is missing for the last loaded thread.
    case missingContactId

    /// Thread is missing the timestamp of when the message was created.
    case invalidOldestDate


    // MARK: - Properties

    var errorDescription: String? {
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
        case .anonymousAuthorizationFailure:
            return "Something went wrong and the customer could not be authorized."
        case .oAuthAuthorizationFailure:
            return "Something went wrong and the channel configuration could not be retrieved."
        case .missingAuthCode:
            return "You are trying to authorize a customer through OAuth, but haven’t provided the authorization code yet."
                + " Make sure you call setAuthCode before calling connect."
        case .reconnectFailure:
            return "Something went wrong and the returning customer could not be reconnected."
        case .missingAccessToken:
            return "The customer was successfully authorized using OAuth, but an access token wasn’t returned."
        case .missingCustomerId:
            return "The customer was successfully authorized using OAuth, but a customerId wasn’t returned."
        case .customerVisitorAssociationFailure:
            return "The customer could not be successfully associated with a visitor."
        case .invalidCaseId:
            return "Could not update customer contact field; need to send a message first to open channel."
        case .serverError:
            return "Internal server error."
        case .invalidRequest:
            return "Could not make the request because the URL was malformed."
        case .invalidCustomerId:
            return "The customer id is not valid."
        case .missingContactId:
            return "Missing contact id."
        case .invalidOldestDate:
            return "No oldest message date is saved."
        case .missingParameter(let param):
            return "Parameter \"\(param)\" was in an unexpected format or missing."
        }
    }


    // MARK: - Methods

    static func == (lhs: Self, rhs: Self) -> Bool {
        type(of: lhs) == type(of: rhs) && lhs.localizedDescription == rhs.localizedDescription
    }
}
