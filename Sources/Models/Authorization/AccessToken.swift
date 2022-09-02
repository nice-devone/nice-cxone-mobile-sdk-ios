import Foundation

/// An access token used by the customer for sending messages if OAuth authorization is on for the channel.
internal struct AccessToken: Codable {
    
    /// The actual token value.
    let token: String
    
    /// The number of seconds before the access token becomes invalid.
    private let expiresIn: Int

    /// The date at which this access token was created.
    private let currentDate: Date
    
    /// Whether the token has expired or not.
    public var isExpired: Bool {
//        guard let currentDate = currentDate else {return false}
        let date = Calendar.current.dateComponents([.second], from: currentDate, to: Date())
        return date.second ?? 0 > (expiresIn - 180)
    }
    enum CodingKeys: String, CodingKey {
        case token = "token"
        case currentDate = "currentDate"
        case expiresIn = "expiresIn"
    }
    
    public init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        token = try values.decode(String.self, forKey: .token)
        expiresIn = try values.decode(Int.self, forKey: .expiresIn)
        let date = try values.decodeIfPresent(Date.self, forKey: .currentDate)
        if let date = date {
            self.currentDate = date
        } else {
            self.currentDate = Date()
        }
    }
    internal init(token: String, expiresIn: Int) {
        self.token = token
        self.expiresIn = 180
        self.currentDate = Date()
    }
}
