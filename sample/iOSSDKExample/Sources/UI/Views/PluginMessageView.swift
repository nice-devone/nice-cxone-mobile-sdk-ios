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
import SafariServices
import UIKit

protocol PluginMessageDelegate: AnyObject {
    func pluginMessageView(_ view: PluginMessageView, quickReplySelected option: String, withPostback postback: String?)
    func pluginMessageView(_ view: PluginMessageView, subElementDidTap subElement: PluginMessageSubElementType)
}

/// View to display for the plugin messages.
class PluginMessageView: UIView {
    
    // MARK: - Properties
    
    private var messageType: PluginMessageType?
    
    private var stackView = UIStackView()
    
    weak var delegate: PluginMessageDelegate?
    
    var isOptionSelectionEnabled = true {
        didSet {
            stackView.arrangedSubviews.forEach { subview in
                (subview as? PrimaryButton)?.isEnabled = isOptionSelectionEnabled
            }
        }
    }
    
    // MARK: - Init
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    init() {
        super.init(frame: .zero)
        
        setupStackView()
    }
    
    // MARK: - Methods
    
    func configure(with messageType: PluginMessageType) {
        guard self.messageType == nil else {
            return
        }
        
        self.messageType = messageType
        
        handleMessageType(messageType, in: &stackView)
    }
}

// MARK: - Actions

private extension PluginMessageView {

    @objc
    func quickReplyButtonTapped(sender: PrimaryButton) {
        guard let title = sender.title(for: .normal) else {
            Log.error(CommonError.unableToParse("title", from: sender))
            return
        }
        
        isOptionSelectionEnabled = false
        
        delegate?.pluginMessageView(self, quickReplySelected: title, withPostback: sender.postback)
    }
    
    @objc
    func customVariableButtonDidTap(sender: PrimaryButton) {
        guard let id = sender.identifier else {
            Log.error(CommonError.unableToParse("id", from: sender))
            return
        }
        guard let title = sender.title(for: .normal) else {
            Log.error(CommonError.unableToParse("title", from: sender))
            return
        }
        
        delegate?.pluginMessageView(self, subElementDidTap: .button(PluginMessageButton(id: id, text: title, postback: nil, url: nil, displayInApp: false)))
    }
}

// MARK: - Private methods

private extension PluginMessageView {
    
    func handleMessageType(_ type: PluginMessageType, in stackView: inout UIStackView) {
        switch type {
        case .textAndButtons(let entity):
            setupTextAndButtons(entity, in: &stackView)
        case .satisfactionSurvey(let entity):
            setupSatisfactionSurvey(entity, in: &stackView)
        case .menu(let entity):
            setupMenu(entity, in: &stackView)
        case .quickReplies(let entity):
            setupQuickReplies(entity, in: &stackView)
        case .gallery(let entities):
            let scrollView = UIScrollView()
            scrollView.isUserInteractionEnabled = true
            scrollView.showsHorizontalScrollIndicator = false
            addSubview(scrollView)
            
            scrollView.snp.makeConstraints { make in
                make.edges.equalToSuperview()
            }
            
            stackView.removeFromSuperview()
            stackView.snp.removeConstraints()
            scrollView.addSubview(stackView)
            stackView.axis = .horizontal
            stackView.distribution = .fill
            
            stackView.snp.makeConstraints { make in
                make.edges.height.equalToSuperview()
            }
            
            setupGallery(entities, in: &stackView)
        case .subElements(let subElements):
            subElements.forEach { subElement in
                setupSubElement(subElement, into: &stackView)
            }
        case .custom(let entity):
            setupCustomVariables(entity.variables, in: &stackView)
        }
    }
    
    func setupTextAndButtons(_ element: PluginMessageTextAndButtons, in stackView: inout UIStackView) {
        element.elements.forEach { subElement in
            setupSubElement(subElement, into: &stackView)
        }
    }
    
    func setupSatisfactionSurvey(_ element: PluginMessageSatisfactionSurvey, in stackView: inout UIStackView) {
        element.elements.forEach { subElement in
            setupSubElement(subElement, into: &stackView)
        }
    }
    
    func setupMenu(_ element: PluginMessageMenu, in stackView: inout UIStackView) {
        element.elements.forEach { subElement in
            setupSubElement(subElement, into: &stackView)
        }
    }
    
    func setupQuickReplies(_ element: PluginMessageQuickReplies, in stackView: inout UIStackView) {
        element.elements.forEach { subElement in
            guard case .button(let entity) = subElement else {
                setupSubElement(subElement, into: &stackView)
                return
            }
            
            let button = PrimaryButton()
            button.postback = entity.postback
            button.isEnabled = isOptionSelectionEnabled
            button.setTitle(entity.text, for: .normal)
            button.addTarget(self, action: #selector(quickReplyButtonTapped), for: .touchUpInside)
            button.layer.cornerRadius = CustomMessageSizeCalculator.buttonHeight / 2
            
            button.snp.makeConstraints { make in
                make.height.equalTo(CustomMessageSizeCalculator.buttonHeight)
            }
            
            stackView.addArrangedSubview(button)
        }
    }
    
    func setupGallery(_ elements: [PluginMessageType], in stackView: inout UIStackView) {
        elements.forEach { entity in
            var subStackView = UIStackView()
            stackView.addArrangedSubview(subStackView)
            subStackView.axis = .vertical
            subStackView.distribution = .fillProportionally
            subStackView.spacing = 10
            
            handleMessageType(entity, in: &subStackView)
        }
    }
    
    func setupCustomVariables(_ variables: [String: Any], in stackView: inout UIStackView) {
        // Currently support only buttons
        guard let buttons = variables["buttons"] as? [[String: String]] else {
            Log.error("Only buttons with color and size are currently supported for a custom plugin.")
            return
        }
        guard let color = variables["color"] as? String else {
            Log.error(.unableToParse("color", from: variables))
            return
        }
        guard let size = variables["size"] as? [String: String] else {
            Log.error(.unableToParse("color", from: variables))
            return
        }
        
        buttons.forEach { button in
            guard let id = button["id"] else {
                Log.error(.unableToParse("id", from: button))
                return
            }
            guard let title = button["name"]else {
                Log.error(.unableToParse("name", from: button))
                return
            }
            
            let button = PrimaryButton()
            button.identifier = id
            button.setTitle(title, for: .normal)
            button.backgroundColor = UIColor(hexString: color)
            button.addTarget(self, action: #selector(customVariableButtonDidTap), for: .touchUpInside)
            
            button.snp.makeConstraints { make in
                make.height.equalTo(UIButton.getSize(for: size["ios"]))
            }
            
            stackView.addArrangedSubview(button)
        }
    }
    
    @objc
    func subElementDidTap(_ sender: SubElementButton) {
        self.isUserInteractionEnabled = false
        
        delegate?.pluginMessageView(self, subElementDidTap: sender.subElement)
    }
    
    func setupSubElement(_ subElement: PluginMessageSubElementType, into stackView: inout UIStackView) {
        switch subElement {
        case .text(let entity):
            let label = UILabel()
            label.numberOfLines = 0
            label.font = .preferredFont(forTextStyle: .body)
            label.text = entity.text
            
            stackView.addArrangedSubview(label)
        case .title(let entity):
            let label = UILabel()
            label.numberOfLines = 0
            label.font = .preferredFont(forTextStyle: .title2)
            label.textAlignment = .center
            label.text = entity.text
            
            stackView.addArrangedSubview(label)
        case .button(let entity):
            let button = SubElementButton(subElement: subElement)
            button.postback = entity.postback
            button.addTarget(self, action: #selector(subElementDidTap), for: .touchUpInside)
            button.setTitle(entity.text, for: .normal)
            button.layer.cornerRadius = CustomMessageSizeCalculator.buttonHeight / 2
            
            button.snp.makeConstraints { make in
                make.height.equalTo(CustomMessageSizeCalculator.buttonHeight)
            }
            
            stackView.addArrangedSubview(button)
        case .file(let entity):
            let imageView = UIImageView()
            imageView.contentMode = .scaleAspectFit
            imageView.load(url: entity.url)
            imageView.layer.cornerRadius = 5

            imageView.snp.makeConstraints { make in
                make.height.equalTo(CustomMessageSizeCalculator.imageHeight)
            }
            
            stackView.addArrangedSubview(imageView)
        }
    }
    
    func setupStackView() {
        addSubview(stackView)
        stackView.isUserInteractionEnabled = true
        stackView.axis = .vertical
        stackView.distribution = .equalSpacing
        stackView.spacing = 10

        stackView.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.leading.trailing.equalToSuperview().inset(10)
            make.top.bottom.lessThanOrEqualToSuperview().inset(10)
        }
    }
}

// MARK: - Helpers

private extension UIButton {

    static func getSize(for value: String?) -> CGFloat {
        switch value {
        case "big":
            return CustomMessageSizeCalculator.buttonHeight * 1.2
        case "middle":
            return CustomMessageSizeCalculator.buttonHeight
        case "small":
            return CustomMessageSizeCalculator.buttonHeight * 0.8
        default:
            return CustomMessageSizeCalculator.buttonHeight * 0.6
        }
    }
}

private class SubElementButton: PrimaryButton {
    
    // MARK: - Properties
    
    let subElement: PluginMessageSubElementType

    // MARK: - Init
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    init(subElement: PluginMessageSubElementType) {
        self.subElement = subElement
        super.init()
    }
}
