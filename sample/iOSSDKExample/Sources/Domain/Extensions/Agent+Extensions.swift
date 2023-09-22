import CXoneChatSDK
import Foundation
import MessageKit

extension Agent: SenderType {
    
    public var senderId: String { String(id) }
    public var displayName: String { fullName }
}
