import Foundation

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
