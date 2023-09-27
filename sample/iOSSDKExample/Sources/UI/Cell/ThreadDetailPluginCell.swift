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

class ThreadDetailPluginCell: MessageContentCell {
    
    // MARK: - Properties
    
    private var message: MessageType?
    
    weak var pluginDelegate: PluginMessageDelegate? {
        get { pluginMessageView.delegate }
        set { pluginMessageView.delegate = newValue }
    }
    
    var isOptionSelectionEnabled = true
    
    // MARK: - Views
    
    private lazy var pluginMessageView = PluginMessageView()
    
    // MARK: - Lifecycle
    
    override func setupSubviews() {
        super.setupSubviews()
        
        messageContainerView.addSubview(pluginMessageView)
        messageContainerView.isUserInteractionEnabled = true
        
        pluginMessageView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
    
    // MARK: - Methods
    
    override func configure(with message: MessageType, at indexPath: IndexPath, and messagesCollectionView: MessagesCollectionView) {
        guard self.message == nil else {
            return
        }
        
        self.message = message
        
        guard case .custom(let entity) = message.kind, let payload = entity as? MessagePlugin else {
            fatalError("ThreadDetailPluginCell received unhandled MessageDataType: \(message.kind)")
        }
        
        pluginMessageView.isOptionSelectionEnabled = isOptionSelectionEnabled
        pluginMessageView.configure(with: payload.element)
        
        super.configure(with: message, at: indexPath, and: messagesCollectionView)
    }
    
    override func handleTapGesture(_ gesture: UIGestureRecognizer) {
        
    }
}
