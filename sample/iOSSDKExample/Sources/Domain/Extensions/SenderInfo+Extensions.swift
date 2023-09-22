import CXoneChatSDK
import Foundation
import MessageKit

extension SenderInfo: SenderType {
    
    public var senderId: String { id }
    public var displayName: String { fullName }
}
