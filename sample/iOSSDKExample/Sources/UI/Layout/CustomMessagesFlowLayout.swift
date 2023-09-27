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
