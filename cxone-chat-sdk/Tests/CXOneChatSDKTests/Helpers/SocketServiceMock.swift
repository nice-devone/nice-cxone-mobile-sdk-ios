//
// Copyright (c) 2021-2023. NICE Ltd. All rights reserved.
//
// Licensed under the NICE License;
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//    https://github.com/nice-devone/nice-cxone-mobile-sdk-ios/blob/main/LICENSE
//
// TO THE EXTENT PERMITTED BY APPLICABLE LAW, THE CXONE MOBILE SDK IS PROVIDED ON
// AN “AS IS” BASIS. NICE HEREBY DISCLAIMS ALL WARRANTIES AND CONDITIONS, EXPRESS
// OR IMPLIED, INCLUDING (WITHOUT LIMITATION) WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE, NON-INFRINGEMENT, AND TITLE.
//

import Foundation
@testable import CXoneChatSDK
import KeychainSwift

class SocketServiceMock: SocketService {
    
    // MARK: - Properties
    
    var pingNumber = 0
    var messageSend = 0
    var messageSent: ((String) -> Void)?
    
    var socket: URLSessionWebSocketTaskProtocol?
    var internalAccessToken: AccessTokenDTO?
    var internalAccessTokenGetterCount = 0
    var internalAccessTokenSetterCount = 0
    
    override var accessToken: AccessTokenDTO? {
        get {
            internalAccessTokenGetterCount += 1
            
            return internalAccessToken
        }
        set {
            internalAccessToken = newValue
            
            if newValue != nil {
                internalAccessTokenSetterCount += 1
            }
        }
    }

    // MARK: - Init
    
    init(session: URLSession = .shared) {
        super.init(keychainSwift: KeychainSwiftMock(), session: session, dateProvider: DateProviderMock())
        
        self.connectionContext = ConnectionContextMock(session: session)
    }
    
    // MARK: - Methods
    
    override func ping() {
        pingNumber += 1
    }
    
    override func send(message: String, shouldCheck: Bool = true) {
        messageSend += 1
        messageSent?(message)
    }
}
