import Foundation

public struct CustomerAuthorizedEventPostbackData: Codable {
    var consumerIdentity: CustomerIdentity
    var accessToken: AccessToken?
}
