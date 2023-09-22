import CXoneChatSDK
import MessageKit
import UIKit

class ThreadDetailListPickerCell: MessageContentCell {
    
    // MARK: - Properties
    
    private var postbacks = [String: String]()
    private var message: MessageType?
    
    weak var messageDelegate: ThreadDetailRichMessageDelegate?
    
    // MARK: - Views
    
    private let titleLabel = UILabel()
    private let textLabel = UILabel()
    private let subElementsStackView = UIStackView()
    
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
        guard case .custom(let entity) = message.kind, let listPicker = entity as? MessageListPicker else {
            Log.error("ThreadDetailListPickerCell received unhandled MessageDataType: \(message.kind)")
            return
        }
        
        self.message = message
        
        titleLabel.text = listPicker.title
        textLabel.text = listPicker.text
        
        listPicker.elements.forEach { element in
            switch element {
            case .replyButton(let button):
                setupReplyButton(with: button)
            }
        }
        
        super.configure(with: message, at: indexPath, and: messagesCollectionView)
    }
}

// MARK: - Actions

private extension ThreadDetailListPickerCell {
    
    @objc
    func optionTapped(_ sender: PrimaryButton) {
        guard let option = postbacks.first(where: { $0.value == sender.title(for: .normal) }) else {
            Log.error(.failed("Could not get a selected option."))
            return
        }

        messageDelegate?.richMessageCell(self, didSelect: option.value, withPostback: option.key)
    }
}

// MARK: - Private methods

private extension ThreadDetailListPickerCell {
    
    func setupReplyButton(with entity: MessageReplyButton) {
        if let postback = entity.postback {
            postbacks[postback] = entity.text
        }
        
        let contentStack = UIStackView()
        subElementsStackView.addArrangedSubview(contentStack)
        
        contentStack.axis = .horizontal
        contentStack.spacing = 10
        
        if let iconUrl = entity.iconUrl {
            let imageView = UIImageView()
            contentStack.addArrangedSubview(imageView)
            
            imageView.layer.masksToBounds = true
            imageView.layer.cornerRadius = CustomMessageSizeCalculator.buttonHeight / 2
            imageView.contentMode = .scaleAspectFill
            imageView.load(url: iconUrl)
            
            imageView.snp.makeConstraints { make in
                make.size.equalTo(CustomMessageSizeCalculator.buttonHeight)
            }
        }
        
        let button = PrimaryButton()
        button.addTarget(self, action: #selector(optionTapped), for: .touchUpInside)
        contentStack.addArrangedSubview(button)
        button.setTitle(entity.text, for: .normal)
        
        button.snp.makeConstraints { make in
            make.height.equalTo(CustomMessageSizeCalculator.buttonHeight)
        }
    }
    
    func setup() {
        messageContainerView.addSubviews(titleLabel, textLabel, subElementsStackView)
        
        messageContainerView.isUserInteractionEnabled = true
        
        titleLabel.font = .preferredFont(forTextStyle: .headline)
        titleLabel.numberOfLines = 0
        titleLabel.textAlignment = .center
        
        textLabel.font = .preferredFont(forTextStyle: .body)
        textLabel.numberOfLines = 0
        textLabel.textAlignment = .center
        
        subElementsStackView.spacing = 10
        subElementsStackView.axis = .vertical
        subElementsStackView.distribution = .fillEqually
        
        titleLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().inset(8)
            make.leading.trailing.equalToSuperview().inset(12)
        }
        
        textLabel.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom)
            make.leading.trailing.equalToSuperview().inset(12)
        }
        
        subElementsStackView.snp.makeConstraints { make in
            make.top.greaterThanOrEqualTo(textLabel.snp.bottom).inset(10)
            make.leading.trailing.equalToSuperview().inset(12)
            make.bottom.equalToSuperview().inset(8)
        }
    }
}
