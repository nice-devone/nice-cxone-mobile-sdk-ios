import MessageKit
import UIKit

extension ThreadDetailViewController: MessagesLayoutDelegate {
    
    func cellTopLabelHeight(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> CGFloat {
        let isTimeLabelVisible = indexPath.section % 3 == 0 && !presenter.isPreviousMessageSameSender(at: indexPath)
        
        return isTimeLabelVisible ? 18 : 0
    }
    
    func messageTopLabelHeight(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> CGFloat {
        if isFromCurrentSender(message: message) {
            return !presenter.isPreviousMessageSameSender(at: indexPath) ? 20 : 0
        } else {
            return !presenter.isPreviousMessageSameSender(at: indexPath) ? (20 + 18) : 0
        }
    }
    
    func messageBottomLabelHeight(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> CGFloat {
        (!presenter.isNextMessageSameSender(at: indexPath) && isFromCurrentSender(message: message)) ? 16 : 0
    }
}
