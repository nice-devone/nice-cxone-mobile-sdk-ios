import CXoneChatSDK
import MessageKit

extension CustomerIdentity: SenderType {
    
    public var senderId: String { id }
    public var displayName: String { fullName ?? "" }
}
