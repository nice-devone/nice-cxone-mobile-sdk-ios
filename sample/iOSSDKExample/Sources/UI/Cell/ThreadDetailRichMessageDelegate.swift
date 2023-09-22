import MessageKit

protocol ThreadDetailRichMessageDelegate: AnyObject {
    
    func richMessageCell(_ cell: MessageContentCell, didSelect option: String, withPostback postback: String)
}
