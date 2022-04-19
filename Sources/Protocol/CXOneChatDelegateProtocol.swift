//
//  File.swift
//  
//
//  Created by kjoe on 2/21/22.
//

import Foundation
@available(iOS 13.0, *)
protocol CXOneChatDelegate {
    func didOpenConnection()
    func didCloseConnection()
    func didReceiveData(_ message : Data)
    func didReceiveError(_ error : Error)
    func didSendPing()
    func refreshToken()
    func handleMessage(message: String)
}
