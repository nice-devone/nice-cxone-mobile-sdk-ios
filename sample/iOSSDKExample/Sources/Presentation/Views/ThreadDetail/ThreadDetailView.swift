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

import ALProgressView
import InputBarAccessoryView
import MessageKit
import UIKit

class ThreadDetailView: BaseView {
    
    // MARK: - Properties
    
    let messagesCollectionView = MessagesCollectionView(frame: .zero, collectionViewLayout: CustomMessagesFlowLayout())
    let messageInputBar = MessagesInputBarAccessoryView()
    let refreshControl = UIRefreshControl()
    let progressRing = ALProgressRing()
    
    // MARK: - Init

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    init() {
        super.init(frame: .zero)

        addSubview(progressRing)
        setupSubviews()
        setupConstraints()
        setupColors()
    }
    
    override func setupColors() {
        backgroundColor = ChatAppearance.backgroundColor
        messagesCollectionView.backgroundColor = ChatAppearance.backgroundColor
        messageInputBar.backgroundColor = ChatAppearance.navigationBarColor
        messageInputBar.tintColor = ChatAppearance.navigationElementsColor
    }
}

// MARK: - Private methods

private extension ThreadDetailView {

    func setupSubviews() {
        progressRing.isHidden = true
        progressRing.startColor = .cyan
        progressRing.grooveColor = .green
        progressRing.endColor = .blue
        
        setupCollectionView()
    }
    
    func setupCollectionView() {
        messagesCollectionView.register(ThreadDetailPluginCell.self)
        messagesCollectionView.register(ThreadDetailRichLinkCell.self)
        messagesCollectionView.register(ThreadDetailQuickRepliesCell.self)
        messagesCollectionView.register(ThreadDetailListPickerCell.self)
        messagesCollectionView.register(ThreadDetailLinkCell.self)
        messagesCollectionView.alwaysBounceVertical = true
        messagesCollectionView.refreshControl = refreshControl
        
        messageInputBar.isTranslucent = false
        
        let layout = messagesCollectionView.collectionViewLayout as? MessagesCollectionViewFlowLayout
        layout?.sectionInset = UIEdgeInsets(top: 1, left: 8, bottom: 1, right: 8)
        
        // Hide the outgoing avatar and adjust the label alignment to line up with the messages
        layout?.setMessageOutgoingAvatarSize(.zero)
        layout?.setMessageOutgoingMessageTopLabelAlignment(
            LabelAlignment(textAlignment: .right, textInsets: UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 8))
        )
        layout?.setMessageOutgoingMessageBottomLabelAlignment(
            LabelAlignment(textAlignment: .right, textInsets: UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 8))
        )
        // Set outgoing avatar to overlap with the message bubble
        layout?.setMessageIncomingMessageTopLabelAlignment(
            LabelAlignment(textAlignment: .left, textInsets: UIEdgeInsets(top: 0, left: 18, bottom: 18, right: 0))
        )
        layout?.setMessageIncomingAvatarSize(CGSize(width: 30, height: 30))
        layout?.setMessageIncomingMessagePadding(UIEdgeInsets(top: -18, left: -18, bottom: 18, right: 18))
        
        layout?.setMessageIncomingAccessoryViewSize(CGSize(width: 30, height: 30))
        layout?.setMessageIncomingAccessoryViewPadding(HorizontalEdgeInsets(left: 8, right: 0))
        layout?.setMessageIncomingAccessoryViewPosition(.messageBottom)
        layout?.setMessageOutgoingAccessoryViewSize(CGSize(width: 30, height: 30))
        layout?.setMessageOutgoingAccessoryViewPadding(HorizontalEdgeInsets(left: 0, right: 8))
    }
    
    func setupConstraints() {
        progressRing.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.size.equalTo(80)
        }
    }
}
