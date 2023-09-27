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

import CXoneChatSDK
import MessageKit
import UIKit

class CustomMessageSizeCalculator: MessageSizeCalculator {
    
    // MARK: - Properties
    
    static let buttonHeight: CGFloat = 44
    static let imageHeight: CGFloat = 150
    
    // MARK: - Init
    
    override init(layout: MessagesCollectionViewFlowLayout? = nil) {
        super.init()
        
        self.layout = layout
    }
    
    // MARK: - Methods
    
    override func messageContainerSize(for message: MessageType, at indexPath: IndexPath) -> CGSize {
        guard let layout = layout else {
            return .zero
        }
        
        let maxWidth = messageContainerMaxWidth(for: message, at: indexPath)
        let contentInset = layout.collectionView?.contentInset ?? .zero
        let inset = layout.sectionInset.left + layout.sectionInset.right + contentInset.left + contentInset.right
        
        guard case .custom(let entity) = message.kind else {
            return CGSize(width: ((maxWidth) - inset), height: ((maxWidth / 2) - inset))
        }
        
        switch entity {
        case let entity as MessagePlugin:
            return CGSize(width: ((maxWidth) - inset), height: calculateHeight(from: entity.element, maxWidth: maxWidth, inset: inset))
        case let entity as MessageRichLink:
            return CGSize(
                width: ((maxWidth) - inset),
                height: Self.imageHeight + entity.title.height(withConstrainedWidth: maxWidth, font: .subheadline) + inset
            )
        case let entity as MessageQuickReplies:
            let labelHeight = entity.title.height(withConstrainedWidth: maxWidth, font: .headline) + inset
            
            return CGSize(
                width: ((maxWidth) - inset),
                height: labelHeight + calculateSubElementsHeight(entity.buttons.map(MessageSubElementType.replyButton)) + inset
            )
        case let entity as MessageListPicker:
            let titleHeight = entity.title.height(withConstrainedWidth: maxWidth, font: .headline) + inset
            let textHeight = entity.text.height(withConstrainedWidth: maxWidth, font: .body)
            
            return CGSize(width: ((maxWidth) - inset), height: titleHeight + textHeight + calculateSubElementsHeight(entity.elements) + inset)
        default:
            return CGSize(width: ((maxWidth) - inset), height: ((maxWidth / 2) - inset))
        }
    }
}

// MARK: - Private methods

private extension CustomMessageSizeCalculator {

    func calculateHeight(from entity: PluginMessageType, maxWidth: CGFloat, inset: CGFloat) -> CGFloat {
        switch entity {
        case .quickReplies(let entity):
            return calculateSubElementsHeight(entity.elements, viewWidth: maxWidth) + inset
        case .textAndButtons(let entity):
            return calculateSubElementsHeight(entity.elements, viewWidth: maxWidth) + inset
        case .satisfactionSurvey(let entity):
            return calculateSubElementsHeight(entity.elements, viewWidth: maxWidth) + (2 * inset)
        case .menu(let entity):
            return calculateSubElementsHeight(entity.elements, viewWidth: maxWidth) + inset
        case .subElements(let entities):
            return calculateSubElementsHeight(entities, viewWidth: maxWidth) + inset
        case .gallery(let entities):
            var elementsHeight: CGFloat = 0
            
            entities.forEach { entity in
                elementsHeight += calculateHeight(from: entity, maxWidth: maxWidth, inset: inset)
            }
            
            return elementsHeight / CGFloat(entities.count)
        case .custom(let entity):
            if let buttons = entity.variables["buttons"] as? [[String: Any]] {
                return CGFloat(buttons.count) * Self.buttonHeight + inset
            } else {
                return (maxWidth / 2) - inset
            }
        }
    }
    
    func calculateSubElementsHeight(_ elements: [PluginMessageSubElementType], viewWidth: CGFloat) -> CGFloat {
        var elementsHeight: CGFloat = 0
        
        elements.forEach { element in
            switch element {
            case .text(let entity):
                elementsHeight += entity.text.height(withConstrainedWidth: viewWidth, font: .body)
            case .file:
                elementsHeight += Self.imageHeight
            case .title(let entity):
                elementsHeight += entity.text.height(withConstrainedWidth: viewWidth, font: .title2)
            case .button:
                elementsHeight += Self.buttonHeight
            }
        }
        
        return elementsHeight
    }
    
    func calculateSubElementsHeight(_ elements: [MessageSubElementType]) -> CGFloat {
        var elementsHeight: CGFloat = 0
        
        elements.forEach { element in
            switch element {
            case .replyButton:
                elementsHeight += Self.buttonHeight
            }
        }
        
        return elementsHeight
    }
}
