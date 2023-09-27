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

class ThreadDetailQuickRepliesCell: MessageContentCell {
    
    // MARK: - Properties
    
    private var options = [String: String]()
    private var message: MessageType?
    
    weak var messageDelegate: ThreadDetailRichMessageDelegate?
    
    var isOptionSelectionEnabled = true {
        didSet {
            optionsStackView.arrangedSubviews.forEach { subview in
                (subview as? PrimaryButton)?.isEnabled = isOptionSelectionEnabled
            }
        }
    }
    
    // MARK: - Views
    
    private let titleLabel = UILabel()
    private let optionsStackView = UIStackView()
    
    // MARK: - Lifecycle
    
    override func setupSubviews() {
        super.setupSubviews()
        
        setup()
    }
    
    // MARK: - Methods
    
    override func configure(with message: MessageType, at indexPath: IndexPath, and messagesCollectionView: MessagesCollectionView) {
        guard self.message == nil else {
            return
        }
        guard case .custom(let entity) = message.kind, let quickReplies = entity as? MessageQuickReplies else {
            Log.error("ThreadDetailQuickRepliesCell received unhandled MessageDataType: \(message.kind)")
            return
        }
        
        self.message = message
        
        titleLabel.text = quickReplies.title
        
        quickReplies.buttons.forEach { button in
            setupOption(with: button)
        }
        
        super.configure(with: message, at: indexPath, and: messagesCollectionView)
    }
}

// MARK: - Actions

private extension ThreadDetailQuickRepliesCell {
    
    @objc
    func optionTapped(_ sender: PrimaryButton) {
        guard let option = options.first(where: { $0.value == sender.title(for: .normal) }) else {
            Log.error(.failed("Could not get a selected option."))
            return
        }
        
        isOptionSelectionEnabled = false
        
        messageDelegate?.richMessageCell(self, didSelect: option.value, withPostback: option.key)
    }
}

// MARK: - Private methods

private extension ThreadDetailQuickRepliesCell {
    
    func setupOption(with button: MessageReplyButton) {
        if let postback = button.postback {
            options[postback] = button.text
        }
        
        let optionButton = PrimaryButton()
        optionButton.addTarget(self, action: #selector(optionTapped), for: .touchUpInside)
        optionsStackView.addArrangedSubview(optionButton)
        optionButton.setTitle(button.text, for: .normal)
        
        optionButton.snp.makeConstraints { make in
            make.height.equalTo(CustomMessageSizeCalculator.buttonHeight)
        }
    }
    
    func setup() {
        messageContainerView.addSubviews(titleLabel, optionsStackView)
        
        messageContainerView.isUserInteractionEnabled = true
        
        titleLabel.font = .preferredFont(forTextStyle: .subheadline)
        titleLabel.numberOfLines = 0
        titleLabel.textAlignment = .center
        
        optionsStackView.spacing = 10
        optionsStackView.axis = .vertical
        optionsStackView.distribution = .fillEqually
        
        titleLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().inset(8)
            make.leading.trailing.equalToSuperview().inset(12)
        }
        
        optionsStackView.snp.makeConstraints { make in
            make.top.greaterThanOrEqualTo(titleLabel.snp.bottom).offset(10)
            make.leading.trailing.equalToSuperview().inset(12)
            make.bottom.equalToSuperview().inset(8)
        }
    }
}
