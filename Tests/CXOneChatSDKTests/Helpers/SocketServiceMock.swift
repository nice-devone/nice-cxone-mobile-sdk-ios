//
// Copyright (c) 2021-2024. NICE Ltd. All rights reserved.
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

class SocketServiceMock: SocketServiceImpl {
    
    // MARK: - Properties
    
    var socketUrl: URL?
    var pingNumber = 0
    var messageSend = 0
    var messageSent: ((String) -> Void)?
    
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
        super.init(connectionContext: ConnectionContextMock(session: session))
    }
    
    // MARK: - Methods
    
    override func ping() {
        pingNumber += 1
    }
    
    override func send(data: Data, shouldCheck: Bool = true) throws {
        guard let utf8string = data.utf8string else {
            throw CXoneChatError.missingParameter("utf8string")
        }
        
        messageSend += 1
        messageSent?(utf8string)
    }
    
    override func connect(socketURL: URL) {
        self.socketUrl = socketURL
        super.connect(socketURL: socketURL)
    }
}
