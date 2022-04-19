//
//  File.swift
//  
//
//  Created by Customer Dynamics Development on 10/26/21.
//

import Foundation
import MessageKit
import SwiftUI

@available(iOS 13.0, *)
public protocol CXOneChatController {
	func threadAdded()
	func messageAddedToThread(_ message: Message)
	func messageAddedToChatView(_ message: Message)
	func typingDidStart()
	func typingDidEnd()
	func agentDidReadMessage(thread: String)
	func agentDidChange()
    func contactFieldsWereSet()
    func customFieldsWereSet()
    func didReceiveError()
    func didReceiveData(data: Data)
    func configurationLoaded(config: ChannelConfiguration)
    func recoverThreadFailed()
    func loadedMoreMessage()
    func clientAuthorized()
    func didReceiveThreads(threads: [ThreadObject])
    func archivedThread()
    func onMessageReceivedFromOtherThread(message: Message)
    func didReceiveMetaData()
}
