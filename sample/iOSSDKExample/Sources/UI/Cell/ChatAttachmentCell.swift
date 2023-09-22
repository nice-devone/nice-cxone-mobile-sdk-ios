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
