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
