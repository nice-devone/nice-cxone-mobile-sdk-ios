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
}
