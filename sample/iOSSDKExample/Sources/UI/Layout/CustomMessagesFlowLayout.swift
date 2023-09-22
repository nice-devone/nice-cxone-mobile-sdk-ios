import MessageKit
import UIKit

class CustomMessagesFlowLayout: MessagesCollectionViewFlowLayout {
    
    // MARK: - Properties
    
    lazy var customMessageSizeCalculator = CustomMessageSizeCalculator(layout: self)
    
    // MARK: - Methods
    
    override func cellSizeCalculatorForItem(at indexPath: IndexPath) -> CellSizeCalculator {
        guard !isSectionReservedForTypingIndicator(indexPath.section) else {
            return typingIndicatorSizeCalculator
        }
        guard case .custom = messagesDataSource.messageForItem(at: indexPath, in: messagesCollectionView).kind else {
            return super.cellSizeCalculatorForItem(at: indexPath)
        }
        
        return customMessageSizeCalculator
    }
    
    override func messageSizeCalculators() -> [MessageSizeCalculator] {
        var superCalculators = super.messageSizeCalculators()
        superCalculators.append(customMessageSizeCalculator)
        
        return superCalculators
    }
}
