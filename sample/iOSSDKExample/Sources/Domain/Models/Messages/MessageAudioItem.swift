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

import AVFoundation
import CXoneChatSDK
import MessageKit
import UIKit

class MessageAudioItem: AudioItem {
    
    // MARK: - Properties
    
    var localUrl: URL?
    
    var url: URL
    
    var duration: Float
    
    var size: CGSize
    
    // MARK: - Init
    
    init(from attachment: Attachment) throws {
        guard let url = URL(string: attachment.url) else {
            throw CommonError.unableToParse("audioPlayer", from: attachment)
        }
        
        self.url = url
        self.size = CGSize(width: 240, height: 40)
        self.duration = 0
        
        FileManager.default.storeRemoteFileLocally(remoteUrl: url, named: url.lastPathComponent) { result in
            switch result {
            case .success(let localUrl):
                self.localUrl = localUrl
            case .failure(let error):
                error.logError()
            }
        }
    }
}
