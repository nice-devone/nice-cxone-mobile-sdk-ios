import Foundation


/// An access token used by the customer for sending messages if OAuth authorization is on for the channel.
struct AccessTokenDTO: Codable {

    // MARK: - Properties

    /// The actual token value.
    let token: String

    /// The number of seconds before the access token becomes invalid.
    let expiresIn: Int

    /// The date at which this access token was created.
    let currentDate: Date

    /// Whether the token has expired or not.
    var isExpired: Bool {
        let date = Calendar.current.dateComponents([.second], from: currentDate, to: Date())

        return date.second ?? 0 > (expiresIn - 180)
    }


    // MARK: - Init

    init(token: String, expiresIn: Int = 180) {
        self.token = token
        self.expiresIn = expiresIn
        self.currentDate = Date()
    }


    // MARK: - Decoder

    enum CodingKeys: String, CodingKey {
        case token
        case currentDate
        case expiresIn
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        self.token = try container.decode(String.self, forKey: .token)
        self.expiresIn = try container.decode(Int.self, forKey: .expiresIn)
        self.currentDate = try container.decodeIfPresent(Date.self, forKey: .currentDate) ?? Date()
    }
}
