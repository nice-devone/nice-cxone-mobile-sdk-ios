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
