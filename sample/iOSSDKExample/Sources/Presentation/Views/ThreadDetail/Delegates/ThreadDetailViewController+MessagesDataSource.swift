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

extension ThreadDetailViewController: MessagesDataSource {
    
    var currentSender: MessageKit.SenderType {
        CXoneChat.shared.customer.get() ?? CustomerIdentity(id: UUID().uuidString, firstName: "", lastName: "")
    }
    
    func numberOfSections(in messagesCollectionView: MessagesCollectionView) -> Int {
        presenter.thread.messages.count
    }
    
    func messageForItem(at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> MessageType {
        presenter.thread.messages[safe: indexPath.section] ?? presenter.thread.messages[0]
    }
    
    // MARK: - Labels
    
    func cellTopLabelAttributedText(for message: MessageType, at indexPath: IndexPath) -> NSAttributedString? {
        guard indexPath.section % 3 == 0 && !presenter.isPreviousMessageSameSender(at: indexPath) else {
            return nil
            
        }
        
        return NSAttributedString(
            string: MessageKitDateFormatter.shared.string(from: message.sentDate),
            attributes: [
                NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 10),
                NSAttributedString.Key.foregroundColor: ChatAppearance.customerCellColor
            ]
        )
    }
    
    func messageTopLabelAttributedText(for message: MessageType, at indexPath: IndexPath) -> NSAttributedString? {
        guard !presenter.isPreviousMessageSameSender(at: indexPath) else {
            return nil
        }
        
        return NSAttributedString(
            string: message.sender.displayName,
            attributes: [NSAttributedString.Key.font: UIFont.preferredFont(forTextStyle: .caption1)]
        )
    }
    
    func messageBottomLabelAttributedText(for message: MessageType, at indexPath: IndexPath) -> NSAttributedString? {
        let currentMessage = presenter.thread.messages[indexPath.section]
        let messageStatus: String
        
        switch currentMessage.userStatistics {
        case .some(let statistics) where statistics.readAt != nil:
            messageStatus = L10n.ThreadDetail.CellMessage.statusRead
        case .some:
            messageStatus = L10n.ThreadDetail.CellMessage.statusDelivered
        case .none:
            messageStatus = L10n.ThreadDetail.CellMessage.statusSent
        }
        
        return NSAttributedString(
            string: messageStatus,
            attributes: [
                .font: UIFont.preferredFont(forTextStyle: .caption2, compatibleWith: UITraitCollection(legibilityWeight: .bold)),
                .foregroundColor: ChatAppearance.customerCellColor
            ]
        )
    }
}
