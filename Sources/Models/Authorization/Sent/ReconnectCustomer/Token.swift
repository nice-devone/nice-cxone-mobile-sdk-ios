import Foundation

public struct Token: Codable {
    let token: String
    
    init?(token: String?) {
        guard let token = token else {
            return nil
        }
        self.token = token
    }
}
