import Foundation

public struct ReconnectCustomerEventData: Codable {
    let accessToken: Token
    
    init?(accessToken: Token?) {
        guard let accessToken = accessToken else {
            return nil
        }
        self.accessToken = accessToken
    }
}
