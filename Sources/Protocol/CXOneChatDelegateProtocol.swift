import Foundation
@available(iOS 13.0, *)
protocol CXOneChatDelegate {
    func didCloseConnection()
    func didReceiveError(_ error : Error)
    func refreshToken() throws
    func handleMessage(message: String)
}
