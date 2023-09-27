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

class ThreadDetailLinkCell: MessageContentCell {

    // MARK: - Properties
    
    var messageLabel = MessageLabel()
    
    private var linkURL: URL?
    
    override weak var delegate: MessageCellDelegate? {
        didSet {
            messageLabel.delegate = delegate
        }
    }
    
    // MARK: - Views
    
    private lazy var linkPreviewView: ThreadDetailLinkView = {
        let view = ThreadDetailLinkView()
        view.translatesAutoresizingMaskIntoConstraints = false
        messageContainerView.addSubview(view)

        view.snp.makeConstraints { make in
            make.top.equalTo(messageContainerView.snp.top).offset(messageLabel.textInsets.top)
            make.leading.equalTo(messageContainerView.snp.leading).offset(messageLabel.textInsets.left)
            make.trailing.equalTo(messageContainerView.snp.trailing).offset(-messageLabel.textInsets.right)
            make.bottom.equalTo(messageContainerView.snp.bottom).offset(-messageLabel.textInsets.bottom)
        }
        
        return view
    }()

    // MARK: - Lifecycle
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        messageLabel.attributedText = nil
        messageLabel.text = nil
        linkPreviewView.titleLabel.text = nil
        linkPreviewView.imageView.image = nil
        linkURL = nil
    }
    
    override func setupSubviews() {
        super.setupSubviews()
        
        messageContainerView.addSubview(messageLabel)
    }
    
    // MARK: - Methods

    override func apply(_ layoutAttributes: UICollectionViewLayoutAttributes) {
        super.apply(layoutAttributes)
        
        if let attributes = layoutAttributes as? MessagesCollectionViewLayoutAttributes {
            messageLabel.textInsets = attributes.messageLabelInsets
            messageLabel.font = attributes.messageLabelFont
            messageLabel.frame = messageContainerView.bounds
        }
    }
    
    override func configure(with message: MessageType, at indexPath: IndexPath, and messagesCollectionView: MessagesCollectionView) {
        let displayDelegate = messagesCollectionView.messagesDisplayDelegate

        if let textColor: UIColor = displayDelegate?.textColor(for: message, at: indexPath, in: messagesCollectionView) {
            linkPreviewView.titleLabel.textColor = textColor
        }

        guard case MessageKind.linkPreview(let linkItem) = message.kind else {
            fatalError("LinkPreviewMessageCell received unhandled MessageDataType: \(message.kind)")
        }

        super.configure(with: message, at: indexPath, and: messagesCollectionView)

        linkPreviewView.titleLabel.text = linkItem.teaser
        linkPreviewView.imageView.image = linkItem.thumbnailImage
        linkURL = linkItem.url

        displayDelegate?.configureLinkPreviewImageView(linkPreviewView.imageView, for: message, at: indexPath, in: messagesCollectionView)
        
        guard let displayDelegate = messagesCollectionView.messagesDisplayDelegate else {
            Log.error(.failed("MessagesDisplayDelegate has not been set."))
            return
        }

        let enabledDetectors = displayDelegate.enabledDetectors(for: message, at: indexPath, in: messagesCollectionView)

        messageLabel.configure {
            messageLabel.enabledDetectors = enabledDetectors
            
            for detector in enabledDetectors {
                let attributes = displayDelegate.detectorAttributes(for: detector, and: message, at: indexPath)
                messageLabel.setAttributes(attributes, detector: detector)
            }
            
            switch message.kind {
            case .text(let text), .emoji(let text):
                let textColor = displayDelegate.textColor(for: message, at: indexPath, in: messagesCollectionView)
                messageLabel.text = text
                messageLabel.textColor = textColor
                if let font = messageLabel.font {
                    messageLabel.font = font
                }
            case .attributedText(let text):
                messageLabel.attributedText = text
            default:
                break
            }
        }
    }

    override func handleTapGesture(_ gesture: UIGestureRecognizer) {
        let touchLocation = gesture.location(in: linkPreviewView)

        guard linkPreviewView.frame.contains(touchLocation), let url = linkURL else {
            super.handleTapGesture(gesture)
            return
        }
        
        delegate?.didSelectURL(url)
    }
    
    override func cellContentView(canHandle touchPoint: CGPoint) -> Bool {
        messageLabel.handleGesture(touchPoint)
    }
}

// MARK: - ThreadDetailLinkView

private class ThreadDetailLinkView: UIView {
    
    // MARK: - Views
    
    lazy var imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.clipsToBounds = true
        imageView.contentMode = .scaleAspectFit
        imageView.image = Asset.Message.link
        imageView.translatesAutoresizingMaskIntoConstraints = false

        return imageView
    }()
    lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        
        return label
    }()

    // MARK: - Init
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    init() {
        super.init(frame: .zero)

        addSubviews(imageView, titleLabel)
        
        imageView.snp.makeConstraints { make in
            make.top.equalToSuperview().inset(8)
            make.centerX.equalToSuperview()
            make.leading.greaterThanOrEqualToSuperview()
            make.size.equalTo(30)
        }
        titleLabel.snp.makeConstraints { make in
            make.top.greaterThanOrEqualTo(imageView.snp.bottom).offset(4)
            make.centerX.equalToSuperview()
            make.leading.trailing.equalToSuperview().inset(20)
            make.bottom.equalToSuperview()
        }
    }
}
