import CXoneChatSDK
import MessageKit
import UIKit

/// Entity which handles URL link item
class MessageLinkItem: LinkItem {
    
    // MARK: - Properties
    
    var text: String?
    var attributedText: NSAttributedString?
    var url: URL
    var title: String?
    var teaser: String
    var thumbnailImage: UIImage
    
    // MARK: - Init
    
    init?(attachment: Attachment) {
        guard let url = URL(string: attachment.url) else {
            return nil
        }
        
        self.text = ""
        self.teaser = attachment.friendlyName
        self.url = url
        self.thumbnailImage = Asset.Message.link
    }
}
