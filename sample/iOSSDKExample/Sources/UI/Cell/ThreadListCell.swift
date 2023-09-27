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

class ThreadListCell: UITableViewCell {
    
    // MARK: - Views
    
    let avatarView = AvatarView(frame: CGRect(x: 0, y: 0, width: 70, height: 70))
	let nameLabel = UILabel()
	let lastMessageLabel = UILabel()
    
    // MARK: - Init
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
	override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
		super.init(style: style, reuseIdentifier: reuseIdentifier)
		
		addAllSubviews()
        setupSubviews()
        setupConstraints()
	}
    
    // MARK: - Lifecycle
    
    override func prepareForReuse() {
        avatarView.initials = ""
        lastMessageLabel.text = ""
        nameLabel.text = ""
    }
}

// MARK: - Private methods

extension ThreadListCell {
    
    func configure(thread: ChatThread, isMultiThread: Bool) {
        let agentName = thread.name?.mapNonEmpty { $0 }
            ?? thread.assignedAgent?.fullName.mapNonEmpty { $0 }
            ?? L10n.ThreadList.noAgent
        nameLabel.text = agentName

        avatarView.initials = agentName.components(separatedBy: " ").reduce(into: "") { result, name in
            if let character = name.first {
                result += String(character)
            } else {
                result += ""
            }
        }

        if let kind = thread.messages.last?.kind {
            switch kind {
            case .text(let string):
                lastMessageLabel.text = string
            case .photo:
                lastMessageLabel.text = L10n.ThreadList.Cell.CustomMessage.image
            case .linkPreview(let item):
                lastMessageLabel.text = item.teaser
            case .audio:
                lastMessageLabel.text = L10n.ThreadList.Cell.CustomMessage.audio
            case .video:
                lastMessageLabel.text = L10n.ThreadList.Cell.CustomMessage.video
            case .custom:
                switch thread.messages.last?.contentType {
                case .text(let text):
                    lastMessageLabel.text = text.text
                case .plugin(let plugin):
                    lastMessageLabel.text = plugin.text.mapNonEmpty { $0 }
                        ?? plugin.postback?.mapNonEmpty { $0 }
                        ?? L10n.ThreadList.Cell.CustomMessage.richContent
                case .richLink(let richLink):
                    lastMessageLabel.text = richLink.title
                case .quickReplies(let quickReplies):
                    lastMessageLabel.text = quickReplies.title
                case .listPicker(let listPicker):
                    lastMessageLabel.text = listPicker.text
                default:
                    lastMessageLabel.text = L10n.ThreadList.Cell.CustomMessage.unsupported
                }
            default:
                Log.warning("unknown message kind - \(String(describing: thread.messages.last?.kind))")
            }
        }
    }
}

// MARK: - Private methods

private extension ThreadListCell {

    func addAllSubviews() {
        addSubviews(avatarView, nameLabel, lastMessageLabel)
    }
    
    func setupSubviews() {
        nameLabel.font = .preferredFont(forTextStyle: .title3, compatibleWith: UITraitCollection(legibilityWeight: .bold))
        
        lastMessageLabel.numberOfLines = 2
        lastMessageLabel.font = .preferredFont(forTextStyle: .body)
    }
    
    func setupConstraints() {
        avatarView.snp.makeConstraints { make in
            make.top.leading.bottom.equalToSuperview().inset(10)
            make.width.equalTo(avatarView.snp.height)
        }
        nameLabel.snp.makeConstraints { make in
            make.top.trailing.equalToSuperview().inset(10)
            make.leading.equalTo(avatarView.snp.trailing).offset(10)
            make.height.equalTo(20)
        }
        lastMessageLabel.snp.makeConstraints { make in
            make.top.equalTo(nameLabel.snp.bottom).offset(6)
            make.leading.equalTo(avatarView.snp.trailing).offset(10)
            make.trailing.equalToSuperview().inset(10)
        }
    }
}
