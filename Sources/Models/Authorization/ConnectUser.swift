//
//  Created by Customer Dynamics Development on 9/29/21.
//

import Foundation

/// Used to authorize a user to connect to a WebSocket.
public struct ConnectUser: Codable {
	public var action: String
	public var eventId: String
	public var payload: ConnectUserPayload
}


/// The `payload` in the `ConnectUser` struct
public struct ConnectUserPayload: Codable {
	public var brand: Brand
	public var channel: Channel
	public var data: ConnectUserAuth
	public var consumerIdentity: CustomerIdentity
	public var eventType: String
}


/// The `data` in the `ConnectUserPayload`
public struct ConnectUserAuth: Codable {
	public var authorization: ConnectUserAuthCode
}


/// The `authorization` in the `ConnectUserAuth`
public struct ConnectUserAuthCode: Codable {
	public var authorizationCode: String?
    
    /// Optional, only needed for OAuth with code verifier.
    public var codeVerifier: String?
}

public struct AuthorizeConsumerSuccess: Codable {
    public var eventId: String
    public var postback: AuthorizeConsumerPostback
    
}
public struct AuthAuthorizeConsumerSuccess: Codable {
    public var eventId: String
    public var postback: AuthAuthorizeConsumerPostback
    
}
public struct AuthorizeConsumerPostback: Codable {
    public var eventType: String
    public var data: AuthorizeConsumerData
}
public struct AuthorizeConsumerData: Codable {
    var consumerIdentity: CustomerIdentity
    var accessToken: AccessToken?
}
public struct AuthAuthorizeConsumerData: Codable {
    var consumerIdentity: CustomerIdentity
    var accessToken: AccessToken?
}
public struct AuthAuthorizeConsumerPostback: Codable {
    public var eventType: String
    public var data: AuthAuthorizeConsumerData
}
struct AccessTokenPayload {
    let token: String
}

extension AccessTokenPayload {
    init?(token: String?) {
        if token == nil {
            return nil
        }else {
            self.init(token: token!)
        }
    }
}

extension AccessTokenPayload: Codable {}
struct RefreshToken: Codable {
    public var action: String
    public var eventId: String
    public var payload: RefreshTokenPayload
}
public struct RefreshTokenPayload: Codable {
    public var eventType: String
    public var brand: Brand
    public var channel: Channel
    public var consumerIdentity: CustomerIdentity
    var data: RefreshTokenPayloadData
}
struct RefreshTokenPayloadData: Codable {
    let accessToken: AccessTokenPayload
}

struct TokenRefreshed: Codable {
    public var eventId: String
    public var postback: TokenRefreshedPostback
}

struct TokenRefreshedPostback: Codable {
    let data: TokenRefreshedData
}
struct TokenRefreshedData: Codable {
    let accessToken: AccessToken
}

public struct ReconnectUserData {
    let accessToken: Token
}

extension ReconnectUserData: Codable {}
extension ReconnectUserData {
    init?(accessToken: Token?) {
        if accessToken == nil {
            return nil
        }else {
            self.init(accessToken: accessToken!)
        }
    }
}

public struct Token {
    let token: String
}
extension Token: Codable {}

extension Token {
    init?(token: String?) {
        if token == nil {
            return nil
        }else {
            self.init(token: token!)
        }
    }
}
