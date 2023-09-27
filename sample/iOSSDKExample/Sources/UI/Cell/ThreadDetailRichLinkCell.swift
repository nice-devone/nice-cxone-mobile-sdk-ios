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

class ThreadDetailRichLinkCell: MessageContentCell {
    
    // MARK: - Properties
    
    private var message: MessageType?
    
    // MARK: - Views
    
    private let imageView = UIImageView()
    private let titleLabel = UILabel()
    
    var linkUrl: URL?
    
    // MARK: - Lifecycle
    
    override func setupSubviews() {
        super.setupSubviews()
        
        messageContainerView.addSubviews(imageView, titleLabel)
        
        messageContainerView.isUserInteractionEnabled = true
        
        imageView.contentMode = .scaleAspectFill
        
        titleLabel.font = .preferredFont(forTextStyle: .subheadline)
        titleLabel.numberOfLines = 0
        titleLabel.textAlignment = .center
        
        imageView.snp.makeConstraints { make in
            make.top.leading.trailing.equalToSuperview()
            make.height.equalTo(CustomMessageSizeCalculator.imageHeight)
        }
        
        titleLabel.snp.makeConstraints { make in
            make.top.equalTo(imageView.snp.bottom)
            make.leading.trailing.bottom.equalToSuperview()
        }
    }
    
    // MARK: - Methods
    
    override func configure(with message: MessageType, at indexPath: IndexPath, and messagesCollectionView: MessagesCollectionView) {
        guard self.message == nil else {
            return
        }
        guard case .custom(let entity) = message.kind, let richLink = entity as? MessageRichLink else {
            Log.error("ThreadDetailRichLinkCell received unhandled MessageDataType: \(message.kind)")
            return
        }
        
        self.message = message
        self.linkUrl = richLink.url
        
        imageView.load(url: richLink.fileUrl)
        
        titleLabel.attributedText = NSAttributedString(string: richLink.title, attributes: [.underlineStyle: NSUnderlineStyle.single.rawValue])
        titleLabel.backgroundColor = UIApplication.isDarkModeActive ? .systemBackground : .lightGray
        
        super.configure(with: message, at: indexPath, and: messagesCollectionView)
    }
}
