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

import UIKit

class ChatAttachmentCell: UICollectionViewCell {
    
    // MARK: - Properties
    
    let containerView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .systemGray6
        view.layer.cornerRadius = 8
        view.clipsToBounds = true
        
        return view
    }()
    
    var padding: UIEdgeInsets = UIEdgeInsets(top: 5, left: 5, bottom: 5, right: 5) {
        didSet {
            updateContainerPadding()
        }
    }
    
    lazy var deleteButton: UIButton = { [weak self] in
        let button = UIButton()
        var attrs: [NSAttributedString.Key: AnyObject] = [
            .font: UIFont.boldSystemFont(ofSize: 15),
            .foregroundColor: UIColor.systemBackground
        ]
        button.setAttributedTitle(NSMutableAttributedString(string: "X", attributes: attrs), for: .normal)
        attrs.updateValue(UIColor.systemBackground.withAlphaComponent(0.5), forKey: .foregroundColor)
        button.setAttributedTitle(NSMutableAttributedString(string: "X", attributes: attrs), for: .highlighted)
        button.layer.cornerRadius = 10
        button.clipsToBounds = true
        button.backgroundColor = .systemBlue
        button.addTarget(self, action: #selector(self?.deleteAttachment), for: .touchUpInside)
        return button
    }()
    
    var attachment: ChatAttachmentManager.Attachment?
    
    var indexPath: IndexPath?
    
    weak var manager: ChatAttachmentManager?
    
    // MARK: - Init
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        contentView.addSubviews(containerView, deleteButton)
        setupConstraints()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        contentView.addSubviews(containerView, deleteButton)
        setupConstraints()
    }
    
    // MARK: - Lifecycle
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        indexPath = nil
        manager = nil
        attachment = nil
    }
}

// MARK: - Actions

extension ChatAttachmentCell {
    
    @objc
    func deleteAttachment() {
        guard let index = indexPath?.row else {
            Log.error(.failed("IndexPath is not set."))
            return
        }
        
        manager?.removeAttachment(at: index)
    }
}

// MARK: - Private methods

extension ChatAttachmentCell {

    func setupConstraints() {
        containerView.snp.makeConstraints { make in
            make.top.equalTo(padding.top)
            make.bottom.equalTo(-padding.bottom)
            make.left.equalTo(padding.left)
            make.right.equalTo(-padding.right)
        }
        
        deleteButton.snp.makeConstraints { make in
            make.top.equalTo(contentView.snp.top)
            make.right.equalTo(contentView.snp.right)
            make.size.equalTo(20)
        }
    }
    
    func updateContainerPadding() {
        containerView.snp.remakeConstraints { remake in
            remake.top.equalTo(padding.top)
            remake.bottom.equalTo(-padding.bottom)
            remake.left.equalTo(padding.left)
            remake.right.equalTo(-padding.right)
        }
    }
}
