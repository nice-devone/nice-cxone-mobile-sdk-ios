import Foundation


protocol SocketDelegate: AnyObject {
    
    func didCloseConnection()
    
    func didReceiveError(_ error: Error)
    
    func refreshToken() throws
    
    func handleMessage(message: String)
}
